
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
elif [[ $NodeName = compute* ]];then
    while [ ! $DATA_IF ]
    do
        system host-if-list -a $NodeName 
        read -p "Please input the data interface:" DATA_IF
    done
fi

if [ "$NodeName" = "controller-0" ];then
    while [ ! $NetName ] 
    do 
        read -p "Please input a provider network name, default [providernet-a]:" NetName
        : ${NetName:=providernet-a}
    done

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
elif [[ $NodeName = compute* ]];then
    while [ ! $NetName ] 
    do 
        read -p "Please input a provider network name, default [providernet-a]:" NetName
        : ${NetName:=providernet-a}
    done
fi

if [[ $NodeName = controller* ]];then
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
elif [[ $NodeName = compute* ]];then
    while [ ! $NovaDisk ]
    do 
        system host-disk-list ${NodeName}
        read -p "please input the disk name to config nova local, such as [sdb]:" NovaDisk
    done

#    while [ ! $ImageSize ]
#    do 
#        #system host-disk-list ${NodeName}
#        read -p "please input the image volume size (GB):" ImageSize
#    done
fi

echo ""
if [[ $NodeName = controller-0 ]];then
    echo ">>> Provider network name: $NetName "
    echo ">>> Provider network type: $NetType "
    if [ "$NetType" = "vlan" ]; then
        echo ">>> Provider Netwrok Vlan range: $VlanMin-$VlanMax "
    fi
fi

if [[ $NodeName = controller* ]];then
    if [[ $NodeName != controller-0 ]];then
        echo ">>> OAM interface: $OAM_IF"
    fi
    echo ">>> Cinder disk: $CinderDisk "
    echo ">>> Cinder size: $CinderSize "
elif [[ $NodeName = compute* ]];then
    echo ">>> Data interface: $DATA_IF"
    echo ">>> Nova disk: $NovaDisk "
    #echo ">>> Image volume size: $ImageSize "
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

echo ">>> Configure provider net and data interface"
if [[ $NodeName = controller-0 ]];then
    neutron providernet-create $NetName --type=$NetType
    if [ "$NetType" = "vlan" ]; then
        neurton providernet-range-create --name $NetName-range1 --range $VlanMin-$VlanMax $NetName
    fi
elif [[ $NodeName = controller* ]];then
    # 在第二台控制节点上配置 OAM网络
    system host-if-modify -c platform -n $OAM_IF --networks oam $NodeName $OAM_IF
elif [[ $NodeName = compute* ]];then
    #在计算节点上绑定数据网络网卡
    system host-if-modify -c data $NodeName $DATA_IF -p $NetName
fi

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
elif [[ $NodeName = compute* ]];then

    echo ">>> Configure Nova Volume <<<"
    NOVA_DISK_UUID=$(system host-disk-list ${NodeName} --nowrap | grep ${NovaDisk} | awk '{print $2}')
    echo "* Nova disk: $NovaDisk, UUID: $NOVA_DISK_UUID"
    #echo "--- Configuring nova-local"
    #NOVA_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${NodeName} ${NOVA_DISK_UUID} ${NovaSize})
    #NOVA_PARTITION_UUID=$(echo ${NOVA_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
    system host-lvg-add ${NodeName} nova-local
    system host-pv-add ${NodeName} nova-local ${NOVA_DISK_UUID}
    system host-lvg-modify -b image -s 10240 ${NodeName} nova-local
fi

read -p "Unlock $NodeName [y/n]" unlock
if [ $unlock = "y" ]; then
	echo "unlock $NodeName"
	system host-unlock $NodeName
fi
