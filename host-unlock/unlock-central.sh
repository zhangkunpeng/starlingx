
#exec > >(tee -i ./unlock.log)
#exec 2>&1

source /etc/nova/openrc


while [ ! $NodeName ] 
do
    system host-list
    read -p "Please input the node name to unlock, default [controller-0]:" NodeName
    : ${NodeName:=controller-0}
done
echo "$NodeName"

if [[ $NodeName = controller-1 ]];then
    while [ ! $OAM_IF ]
    do
        system host-port-list $NodeName 
        read -p "Please input the oam interface:" OAM_IF
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


echo ""
if [[ $NodeName = controller* ]];then
    if [[ $NodeName != controller-0 ]];then
        echo ">>> OAM interface: $OAM_IF"
    fi
    echo ">>> Cinder disk: $CinderDisk "
    echo ">>> Cinder size: $CinderSize "
fi
echo ""

while [ "$Apply" != "y" ]
do 
    read -p "Apply the above configuration? [y/n]:" Apply
    if [ "$Apply" == "n" ];then
        exit 1
    fi
done

#set -x

if [[ $NodeName = controller* ]];then
    echo ">>> Configure Cinder Volume <<<"
    echo "--- Getting cinder disk info ---"
    CINDER_DISK_UUID=$(system host-disk-list ${NodeName} --nowrap | grep ${CinderDisk} | awk '{print $2}')
    echo "* Cinder disk: $CinderDisk, UUID: $CINDER_DISK_UUID"
    echo "--- add cinder-volumes ---"
    CINDER_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${NodeName} ${CINDER_DISK_UUID} ${CinderSize})
    CINDER_PARTITION_UUID=$(echo ${CINDER_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
    echo "--- Wait for partition $CINDER_PARTITION_UUID to be ready."
    while true; do system host-disk-partition-list $NodeName --nowrap | grep $CINDER_PARTITION_UUID | grep 'Ready\|on unlock'; if [ $? -eq 0 ]; then break; fi; sleep 2; done
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
fi

read -p "Unlock $NodeName [y/n]" unlock
if [ $unlock = "y" ]; then
	echo "unlock $NodeName"
	system host-unlock $NodeName
fi
