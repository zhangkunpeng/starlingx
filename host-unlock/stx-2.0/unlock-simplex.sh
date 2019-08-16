
. /usr/bin/tsconfig

OAM_IF=enp2s1
DATAIF=(eth1000 eth1001)
export COMPUTE=controller-0
NOVA_SIZE=34

tee /home/sysadmin/localhost.yml << EOF
external_oam_subnet: 10.10.10.0/24
external_oam_gateway_address: 10.10.10.1
external_oam_floating_address: 10.10.10.3
management_subnet: 192.168.204.0/24
dns_servers:
  - 8.8.4.4
admin_password: 99cloud@SH
ansible_become_pass: 99cloud@SH
docker_registries:
  unified: 172.16.130.131:5000
is_secure_registry: False
system_mode: simplex
EOF

if [ -z ${CONFIG_PATH}/.bootstrap_completed ];then
    sleep 2
    ansible-playbook /usr/share/ansible/stx-ansible/playbooks/bootstrap/bootstrap.yml
fi

source /etc/platform/openrc
system host-if-modify controller-0 $OAM_IF -c platform
system interface-network-assign controller-0 $OAM_IF oam

system ntp-modify ntpservers=0.pool.ntp.org,1.pool.ntp.org



PHYSNET0='physnet0'
PHYSNET1='physnet1'
SPL=/tmp/tmp-system-port-list
SPIL=/tmp/tmp-system-host-if-list
system host-port-list ${COMPUTE} --nowrap > ${SPL}
system host-if-list -a ${COMPUTE} --nowrap > ${SPIL}

i=0
for data_if in ${DATAIF[@]}
do
    PHYSNET=physnet$i
    system datanetwork-add $PHYSNET $NetType
    system host-if-modify -m 1500 -c data ${COMPUTE} $data_if
    system interface-datanetwork-assign ${COMPUTE} $data_if $PHYSNET
    let i++
done

system host-label-assign controller-0 openstack-control-plane=enabled
system host-label-assign controller-0 openstack-compute-node=enabled
system host-label-assign controller-0 openvswitch=enabled
system host-label-assign controller-0 sriov=enabled

echo ">>> Getting root disk info"
ROOT_DISK=$(system host-show ${COMPUTE} | grep rootfs | awk '{print $4}')
ROOT_DISK_UUID=$(system host-disk-list ${COMPUTE} --nowrap | grep ${ROOT_DISK} | awk '{print $2}')
echo "Root disk: $ROOT_DISK, UUID: $ROOT_DISK_UUID"

echo ">>>> Configuring nova-local"

NOVA_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${COMPUTE} ${ROOT_DISK_UUID} ${NOVA_SIZE})
NOVA_PARTITION_UUID=$(echo ${NOVA_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
system host-lvg-add ${COMPUTE} nova-local
system host-pv-add ${COMPUTE} nova-local ${NOVA_PARTITION_UUID}
sleep 2

echo ">>> Wait for partition $NOVA_PARTITION_UUID to be ready."
while true; do system host-disk-partition-list $COMPUTE --nowrap | grep $NOVA_PARTITION_UUID | grep Ready; if [ $? -eq 0 ]; then break; fi; sleep 1; done

echo ">>> Add OSDs to primary tier"

system host-disk-list controller-0
system host-disk-list controller-0 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-0 {}
system host-stor-list controller-0

read -p "Unlock ${COMPUTE} [y/n]" unlock
if [ $unlock = "y" ]; then
	echo "unlock ${COMPUTE}"
	system host-unlock ${COMPUTE}
fi