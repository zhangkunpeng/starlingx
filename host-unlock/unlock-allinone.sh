#! /bin/bash

#exec > >(tee -i ./unlock.log)
#exec 2>&1

source /etc/nova/openrc


while [ ! $NodeName ] 
do
    system host-list
    read -p "Please input the node name to unlock, default [controller-0]:" NodeName
    : ${NodeName:=controller-0}
done

if [[ $NodeName = controller-1 ]];then
    while [ ! $OAM_IF ]
    do
        system host-port-list $NodeName 
        read -p "Please input the oam interface:" OAM_IF
    done
fi

while [ ! $DATA_IF ]
do
    system host-if-list -a $NodeName
    read -p "Please input the data interface:" DATA_IF
done

while [ ! $NetName ]
do 
    read -p "Please input a provider network name, default [providernet-a]:" NetName
    : ${NetName:=providernet-a}
done

if [[ $NodeName = controller-0 ]];then
    while [ "$NetType" != "flat" ] && [ "$NetType" != "vlan" ]
    do 
        read -p "Please input the provider network(${NetName})  type [ flat/vlan ]:" NetType
        if [ "$NetType" = "vlan" ]; then
            read -p "Please input vlan range, min [100]:" VlanMin
            : ${VlanMin:=100}
            read -p "Please input vlan range, max [400]:" VlanMax
            : ${VlanMax:=400}
        fi
    done
fi

while [ ! $CinderDisk ]
do 
    system host-disk-list ${NodeName}
    read -p "please input the disk name to config cinder, such as [sdb]:" CinderDisk
done

while [ ! $CinderSize ]
do 
    system host-disk-list ${NodeName}
    read -p "please input the cinder volume size (GB):" CinderSize
done

while [ ! $NovaDisk ]
do 
    system host-disk-list ${NodeName}
    read -p "please input the disk name to config nova volume, such as [sdc]:" NovaDisk
done

while [ ! $NovaSize ]
do 
    system host-disk-list ${NodeName}
    read -p "please input the cinder volume size (GB):" NovaSize
done


echo ""
echo ">>> Data interface: $DATA_IF"
echo ">>> Provider network name: $NetName "
echo ">>> Provider network type: $NetType "
if [ "$NetType" = "vlan" ]; then
    echo ">>> Provider Netwrok Vlan range: $VlanMin-$VlanMax "
fi
echo ">>> Cinder disk: $CinderDisk "
echo ">>> Cinder size: $CinderSize "
echo ">>> Nova disk: $NovaDisk "
echo ">>> Nova size: $NovaSize "
echo ""

while [ "$Apply" != "y" ]
do 
    read -p "Apply the above configuration? [y/n]:" Apply
done


set -x

if [[ $NodeName = controller-1 ]];then
    echo ">>> Configure oam interface"
    system host-if-modify -n $OAM_IF -c platform --networks oam $NodeName $OAM_IF
fi

if [[ $NodeName = controller-0 ]];then
    echo ">>> Configure provider net and data interface"
    neutron providernet-create $NetName --type=$NetType
    if [ "$NetType" = "vlan" ]; then
        neurton providernet-range-create --name $NetName-range1 --range $VlanMin-$VlanMax $NetName
    fi
fi
system host-if-modify -c data $NodeName $DATA_IF -p $NetName

echo ">>> Configure Cinder Volume <<<"
echo "--- Getting cinder disk info ---"
CINDER_DISK_UUID=$(system host-disk-list ${NodeName} --nowrap | grep ${CinderDisk} | awk '{print $2}')
echo "* Cinder disk: $CinderDisk, UUID: $CINDER_DISK_UUID"
echo "--- add cinder-volumes ---"
CINDER_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${NodeName} ${CINDER_DISK_UUID} ${CinderSize})
CINDER_PARTITION_UUID=$(echo ${CINDER_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
echo "--- Wait for partition $CINDER_PARTITION_UUID to be ready."
if [[ $NodeName = controller-0 ]];then
    while true; do system host-disk-partition-list $NodeName --nowrap | grep $CINDER_PARTITION_UUID | grep Ready; if [ $? -eq 0 ]; then break; fi; sleep 2; done
else
    sleep 30
fi
system host-lvg-add ${NodeName} cinder-volumes
system host-pv-add ${NodeName} cinder-volumes ${CINDER_PARTITION_UUID}

if [[ $NodeName = controller-0 ]];then
    system storage-backend-add lvm -s cinder --confirmed
    system storage-backend-list
    echo "--- Wait backend to be configured."
    sleep 30
    while true; do system storage-backend-list --nowrap | grep cinder | grep configured; if [ $? -eq 0 ]; then break; fi; sleep 10; done
    echo "* cinder backend configured"
fi


echo ">>> Configure Nova Volume <<<"
NOVA_DISK_UUID=$(system host-disk-list ${NodeName} --nowrap | grep ${NovaDisk} | awk '{print $2}')
echo "* Nova disk: $NovaDisk, UUID: $NOVA_DISK_UUID"
echo "--- Configuring nova-local"
NOVA_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${NodeName} ${NOVA_DISK_UUID} ${NovaSize})
NOVA_PARTITION_UUID=$(echo ${NOVA_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
system host-lvg-add ${NodeName} nova-local
system host-pv-add ${NodeName} nova-local ${NOVA_PARTITION_UUID}
sleep 2

echo ">>> Wait for partition $NOVA_PARTITION_UUID to be ready."
if [[ $NodeName = controller-0 ]];then
    while true; do system host-disk-partition-list $NodeName --nowrap | grep $NOVA_PARTITION_UUID | grep Ready; if [ $? -eq 0 ]; then break; fi; sleep 5; done
else
    sleep 30
fi

read -p "Unlock $NodeName [y/n]" unlock
if [ $unlock = "y" ]; then
	echo "unlock $NodeName"
	system host-unlock $NodeName
fi
