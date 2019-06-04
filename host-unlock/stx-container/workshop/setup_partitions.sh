export COMPUTE=controller-0
source /etc/platform/openrc
 
echo ">>> Getting root disk info"
ROOT_DISK=$(system host-show ${COMPUTE} | grep rootfs | awk '{print $4}')
ROOT_DISK_UUID=$(system host-disk-list ${COMPUTE} --nowrap | grep ${ROOT_DISK} | awk '{print $2}')
echo "Root disk: $ROOT_DISK, UUID: $ROOT_DISK_UUID"
 
echo ">>>> Configuring nova-local"
NOVA_SIZE=34
NOVA_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${COMPUTE} ${ROOT_DISK_UUID} ${NOVA_SIZE})
NOVA_PARTITION_UUID=$(echo ${NOVA_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
system host-lvg-add ${COMPUTE} nova-local
system host-pv-add ${COMPUTE} nova-local ${NOVA_PARTITION_UUID}
sleep 2
 
echo ">>> Wait for partition $NOVA_PARTITION_UUID to be ready."
while true; do system host-disk-partition-list $COMPUTE --nowrap | grep $NOVA_PARTITION_UUID | grep Ready; if [ $? -eq 0 ]; then break; fi; sleep 1; done
 
echo ">>>> Extending cgts-vg"
PARTITION_SIZE=6
CGTS_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${COMPUTE} ${ROOT_DISK_UUID} ${PARTITION_SIZE})
CGTS_PARTITION_UUID=$(echo ${CGTS_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
 
echo ">>> Wait for partition $CGTS_PARTITION_UUID to be ready"
while true; do system host-disk-partition-list $COMPUTE --nowrap | grep $CGTS_PARTITION_UUID | grep Ready; if [ $? -eq 0 ]; then break; fi; sleep 1; done
 
system host-pv-add ${COMPUTE} cgts-vg ${CGTS_PARTITION_UUID}
sleep 2
 
echo ">>> Waiting for cgts-vg to be ready"
while true; do system host-pv-list ${COMPUTE} | grep cgts-vg | grep adding; if [ $? -ne 0 ]; then break; fi; sleep 1; done
 
system host-pv-list ${COMPUTE}
