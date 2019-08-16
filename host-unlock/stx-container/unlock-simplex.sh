#! bin/bash

. /etc/platform/platform.conf

source /etc/platform/openrc

while [ ! $NodeName ] 
do
    system host-list
    read -p "Please input the node name to unlock, default [controller-0]:" NodeName
    : ${NodeName:=controller-0}
done

while [ ! $OAM_IF ]
do
    system host-if-list -a $NodeName
    read -p "Please input the oam interface:" OAM_IF
done

if [[ $system_mode = duplex ]];then
    while [ ! $MGMT_IF ]; do
        read -p "Please input the oam interface:" MGMT_IF
    done
else
    MGMT_IF=lo
fi

while [ ! $DATA_IFS ]
do
    read -p "Please input the data interface(s), split with ',' such as (eth1000,eth1001):" DATA_IFS
done
while [ "$NetType" != "flat" ] && [ "$NetType" != "vlan" ]
do 
    read -p "Please input the physnet network type [ flat/vlan ]:" NetType
done

while [ "$VSWITCH_TYPE" != "none" ] && [ "$VSWITCH_TYPE" != "ovs-dpdk" ];do 
    read -p "Please input the vswitch type to config, default[none]:" VSWITCH_TYPE
    : ${VSWITCH_TYPE:=none}
done

echo ""
echo ">>> OAM interface: $OAM_IF"
echo ">>> MGMT interface: $MGMT_IF"
echo ">>> Data interface: $DATA_IFS"
echo ">>> Provider network type: $NetType "
echo ">>> vswitch type: $VSWITCH_TYPE "

while [ "$Apply" != "y" ]
do 
    read -p "Apply the above configuration? [y/n]:" Apply
    if [ "$Apply" == "n" ];then
        exit 1
    fi
done


# system host-if-modify controller-0 lo -c none
# IFNET_UUIDS=$(system interface-network-list controller-0 | awk '{if ($6 =="lo") print $4;}')
# for UUID in $IFNET_UUIDS; do
#     system interface-network-remove ${UUID}
# done

echo ">>> Configure the OAM interface"
system host-if-modify $NodeName $OAM_IF -c platform
system interface-network-assign $NodeName $OAM_IF oam

# echo ">>> Configure the MGMT interface"
# system host-if-modify $NodeName $MGMT_IF -c platform
# system interface-network-assign $NodeName $MGMT_IF mgmt
# system interface-network-assign $NodeName $MGMT_IF cluster-host

echo ">>> Set the ntp server"
system ntp-modify ntpservers=0.pool.ntp.org,1.pool.ntp.org

# echo ">>> Configure the vswitch type"
# system modify --vswitch_type $VSWITCH_TYPE
# if [[ $VSWITCH_TYPE = ovs-dpdk ]]; then
#     system host-cpu-modify -f vswitch -p0 1 controller-0
# fi

echo ">>> Configure data interfaces"
DATA_IF_ARRAY=(${DATA_IFS//,/ })
SPL=/tmp/tmp-system-port-list
SPIL=/tmp/tmp-system-host-if-list
system host-port-list ${NodeName} --nowrap > ${SPL}
system host-if-list -a ${NodeName} --nowrap > ${SPIL}
i=0
for data_if in ${DATA_IF_ARRAY[@]}
do
    PHYSNET=physnet$i
    system datanetwork-add $PHYSNET $NetType
    system host-if-modify -m 1500 -c data $NodeName $data_if
    system interface-datanetwork-assign $NodeName $data_if $PHYSNET
    let i++
done

echo ">>> Prepare the host for running the containerized services"
if [[ $subfunction == *controller* ]];then
    system host-label-assign controller-0 openstack-control-plane=enabled
fi
if [[ $subfunction == *worker* ]];then
    system host-label-assign controller-0 openstack-compute-node=enabled
    system host-label-assign controller-0 openvswitch=enabled
    system host-label-assign controller-0 sriov=enabled
fi

echo ">>> Getting root disk info"
ROOT_DISK=$(system host-show ${NodeName} | grep rootfs | awk '{print $4}')
ROOT_DISK_UUID=$(system host-disk-list ${NodeName} --nowrap | grep ${ROOT_DISK} | awk '{print $2}')
echo "Root disk: $ROOT_DISK, UUID: $ROOT_DISK_UUID"

echo ">>>> Configuring nova-local"
NOVA_SIZE=24
NOVA_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${NodeName} ${ROOT_DISK_UUID} ${NOVA_SIZE})
NOVA_PARTITION_UUID=$(echo ${NOVA_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
system host-lvg-add ${NodeName} nova-local
system host-pv-add ${NodeName} nova-local ${NOVA_PARTITION_UUID}
sleep 2

echo ">>> Wait for partition $NOVA_PARTITION_UUID to be ready."
while true; do system host-disk-partition-list $NodeName --nowrap | grep $NOVA_PARTITION_UUID | grep Ready; if [ $? -eq 0 ]; then break; fi; sleep 1; done

echo ">>> Add OSDs to primary tier"

system host-disk-list controller-0
system host-disk-list controller-0 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-0 {}
system host-stor-list controller-0

read -p "Unlock $NodeName [y/n]" unlock
if [ $unlock = "y" ]; then
	echo "unlock $NodeName"
	system host-unlock $NodeName
fi