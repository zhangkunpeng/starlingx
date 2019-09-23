#!/bin/bash

source /etc/nova/openrc
. /usr/bin/tsconfig

if [ ! -f ${CONFIG_PATH}/.bootstrap_completed ];then
    echo "Bootstrap未完成，请先执行bootstrap操作！！！
======================================================
Step 1. 生成配置文件
cat <<EOF > /home/sysadmin/localhost.yml
# 系统模式，包括 duplex/simplex
system_mode: simplex
timezone: Asia/Shanghai

# 外部访问地址
external_oam_subnet: <OAM-IP-SUBNET>/<OAM-IP-SUBNET-LENGTH>
external_oam_gateway_address: <OAM-GATEWAY-IP-ADDRESS>
external_oam_floating_address: <OAM-FLOATING-IP-ADDRESS>
external_oam_node_0_address: <OAM-CONTROLLER-0-IP-ADDRESS>
external_oam_node_1_address: <OAM-CONTROLLER-1-IP-ADDRESS>

admin_username: admin
# 访问集群密码
admin_password: <sysadmin-password>
# 切换root权限密码
ansible_become_pass: <sysadmin-password>
EOF

Step 2. 执行bootstrap
ansible-playbook /usr/share/ansible/stx-ansible/playbooks/bootstrap/bootstrap.yml
======================================================"
    exit 1
fi
. /etc/platform/platform.conf

log_error(){
    echo $1
    exit 1
}

while getopts "c:" o; do
    case "${o}" in
        c)
            DEPLOY_MODE="$OPTARG"
            ;;
        *)
            echo "$0 [-h] [-c <deploy mode>]"
            echo ""
            echo "Options:"
            echo "  -c: Deploy Mode: simplex, duplex, standard, storage"
            echo ""
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

while [ ! $COMPUTE ] 
do
    system host-list
    read -p "请输入需要配置的节点名称，默认为[controller-0]:" COMPUTE
    : ${COMPUTE:=controller-0}
done

PERSONALITY=$(system host-show $COMPUTE  |grep personality | awk '{print $4}')

while [ ! $OAM_INTERFACE ] 
do
    system host-port-list $COMPUTE
    read -p "请输入外部访问网络接口:" OAM_INTERFACE
done

if [ "$system_mode" != "simplex" ] && [ "$COMPUTE" == "controller-0" ];then
    while [ ! $MGMT_INTERFACE ] 
    do
        system host-port-list $COMPUTE
        read -p "请输入管理网络接口:" MGMT_INTERFACE
    done
fi

: ${MGMT_INTERFACE:=mgmt0}
if [ "$system_mode" == "simplex" ];then
MGMT_INTERFACE=lo
fi

if [[ $PERSONALITY == *worker* ]];then
    while [ ! $DATA_INTERFACE ]
    do
        system host-if-list -a $COMPUTE
        read -p "请输入数据(业务)网络接口:" DATA_INTERFACE
    done

    while [ "$DATE_TYPE" != "flat" ] && [ "$DATE_TYPE" != "vlan" ]
    do 
        read -p "请输入业务网络类型[ flat/vlan ]:" DATE_TYPE
    done

        while [ ! $K8S_SRIOV ]
    do
        system host-if-list -a $COMPUTE
        read -p "是否开启Kubernets SRIOV网络插件,默认不开启，虚拟环境部署请选择n,[y/n]:" K8S_SRIOV
        : ${K8S_SRIOV:=n}
    done

    while [ ! $NOVA_LOCAL_DISK ]
    do 
        system host-disk-list ${COMPUTE}
        read -p "请输入nova服务需要的nova-local卷硬盘，例如[sdc]:" NOVA_LOCAL_DISK
    done

    while [ ! $NOVA_SIZE ]
    do 
        system host-disk-list ${COMPUTE}
        read -p "请输入nova local卷大小 (GB):" NOVA_SIZE
    done
fi
if [ "$COMPUTE" == "controller-0" ];then
    while [ ! $NTPSERVERS ]
    do
        system host-if-list -a $COMPUTE
        read -p "请输入时间同步服务地址，多个地址逗号分割，默认【0.pool.ntp.org,1.pool.ntp.org】:" NTPSERVERS
        : ${NTPSERVERS:=0.pool.ntp.org,1.pool.ntp.org}
    done
fi

if [[ "$DEPLOY_MODE" == "storage" ]] && [[ $PERSONALITY  == *storage* ]];then
    while [ ! $CEPH_OSD_DISK ]
    do 
        system host-disk-list ${COMPUTE}
        read -p "请输入需要配置成ceph osd的硬盘，例如[sdb]:" CEPH_OSD_DISK
    done
    CEPH_OSD_DISK=/dev/$CEPH_OSD_DISK
elif [[ "$DEPLOY_MODE" != "storage" ]] && [[ $PERSONALITY  == *controller* ]];then
    while [ ! $CEPH_OSD_DISK ]
    do 
        system host-disk-list ${COMPUTE}
        read -p "请输入需要配置成ceph osd的硬盘，例如[sdb]:" CEPH_OSD_DISK
    done
    CEPH_OSD_DISK=/dev/$CEPH_OSD_DISK
fi


echo "==============================================="
echo "集群系统模式：$system_mode"
echo "配置节点名称：$COMPUTE"
echo "配置节点角色：$PERSONALITY"
echo "OAM外部网络接口：$OAM_INTERFACE"
echo "MGMT管理网络接口: $MGMT_INTERFACE"
echo "数据（业务）网络接口：$DATA_INTERFACE"
echo "数据（业务）网络类型：$DATE_TYPE"
echo "NTP服务器地址：$NTPSERVERS"
echo "是否开启k8s SRIVO网络插件：$K8S_SRIOV"
echo "CEPH OSD 磁盘: $CEPH_OSD_DISK "
echo "nova local 磁盘: $NOVA_LOCAL_DISK "
echo "nova loacl 大小: $NOVA_SIZE GB "

while [ "$Apply" != "y" ]
do 
    read -p "Apply the above configuration? [y/n]:" Apply
    if [ "$Apply" == "n" ];then
        exit 1
    fi
done

config_net_oam(){
    echo ">>> 配置外部网络"
    system host-if-modify $COMPUTE $OAM_INTERFACE -c platform
    system interface-network-assign $COMPUTE $OAM_INTERFACE oam
}

config_net_mgmt(){
    echo ">>> 配置管理和集群网络"
    if [ "$COMPUTE" == "controller-0" ];then
        system host-if-modify $COMPUTE lo -c none
        IFNET_UUIDS=$(system interface-network-list $COMPUTE | awk '{if ($6=="lo") print $4;}')
        for UUID in $IFNET_UUIDS; do
            system interface-network-remove ${UUID}
        done
        system host-if-modify $COMPUTE $MGMT_INTERFACE -c platform
        system interface-network-assign $COMPUTE $MGMT_INTERFACE mgmt
        system interface-network-assign $COMPUTE $MGMT_INTERFACE cluster-host
    else
        system interface-network-assign $COMPUTE $MGMT_INTERFACE cluster-host
    fi
}

config_net_data(){
    if [[ $PERSONALITY == *worker* ]];then
    echo ">>> 配置数据（业务）网络"
    PHYSNET=physnet0
    system datanetwork-add $PHYSNET $DATE_TYPE
    system host-if-modify -m 1500 -c data ${COMPUTE} $DATA_INTERFACE
    system interface-datanetwork-assign ${COMPUTE} $DATA_INTERFACE $PHYSNET
    fi
}

config_ceph_osd(){
    if [ "$DEPLOY_MODE" == "storage" ];then
        echo ">>> 专用存储节点部署模式"
        if [[ $PERSONALITY  == *storage* ]];then
            DISK_UUID=$(system host-disk-list $COMPUTE |grep $CEPH_OSD_DISK |awk '{print $2}')
            TIER_UUID=$(system storage-tier-list ceph_cluster |grep storage | awk '{print $2}')
            system host-stor-add $COMPUTE $DISK_UUID --tier-uuid $TIER_UUID
            while true; do 
                system host-stor-list ${COMPUTE} | grep ${CEPH_OSD_DISK} | grep configuring; 
                if [ $? -ne 0 ]; then break; fi; 
                sleep 1; 
            done
        fi
    else
        if [[ $PERSONALITY == *controller* ]];then
            echo ">>> 配置ceph osd"
            system host-disk-list $COMPUTE
            DISK_UUID=$(system host-disk-list $COMPUTE |grep $CEPH_OSD_DISK |awk '{print $2}')
            TIER_UUID=$(system storage-tier-list ceph_cluster |grep storage | awk '{print $2}')
            system host-stor-add $COMPUTE $DISK_UUID --tier-uuid $TIER_UUID
            #system host-disk-list controller-0 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-0 {}
            while true; do 
                system host-stor-list ${COMPUTE} | grep ${CEPH_OSD_DISK} | grep configuring; 
                if [ $? -ne 0 ]; then break; fi; 
                sleep 1; 
            done
        elif [ "$COMPUTE" == "compute-0" ];then
            system ceph-mon-add $COMPUTE
            while true; do
                system ceph-mon-list | grep $COMPUTE | grep 'configured'
                if [ $? -eq 0 ]; then break; fi; 
                sleep 1; 
            done
        fi
    fi

}

config_nova_local(){
    if [[ $PERSONALITY == *worker* ]];then
    echo ">>> 配置nova local"
    ROOT_DISK_UUID=$(system host-disk-list ${COMPUTE} --nowrap | grep ${NOVA_LOCAL_DISK} | awk '{print $2}')
    echo "Nova Local disk: $NOVA_LOCAL_DISK, UUID: $ROOT_DISK_UUID"

    echo ">>>> Configuring nova-local"

    NOVA_PARTITION=$(system host-disk-partition-add -t lvm_phys_vol ${COMPUTE} ${ROOT_DISK_UUID} ${NOVA_SIZE})
    NOVA_PARTITION_UUID=$(echo ${NOVA_PARTITION} | grep -ow "| uuid | [a-z0-9\-]* |" | awk '{print $4}')
    system host-lvg-add ${COMPUTE} nova-local
    system host-pv-add ${COMPUTE} nova-local ${NOVA_PARTITION_UUID}
    sleep 2

    echo ">>> Wait for partition $NOVA_PARTITION_UUID to be ready."
    while true; do system host-disk-partition-list $COMPUTE --nowrap | grep $NOVA_PARTITION_UUID | grep 'Ready\|on unlock'; if [ $? -eq 0 ]; then break; fi; sleep 1; done
    fi
}

config_host_label(){
    if [[ $PERSONALITY == *controller* ]];then
        system host-label-assign $COMPUTE openstack-control-plane=enabled
    fi
    if [[ $PERSONALITY == *worker* ]];then
        system host-label-assign $COMPUTE  openstack-compute-node=enabled
        system host-label-assign $COMPUTE  openvswitch=enabled
        system host-label-assign $COMPUTE  sriov=enabled
        if [ "$K8S_SRIOV" == "y" ];then
            system host-label-assign ${COMPUTE} sriovdp=enabled
            system host-memory-modify ${COMPUTE} 0 -1G 100
            system host-memory-modify ${COMPUTE} 1 -1G 100
        fi
    fi
}

config_net_oam
if [ "$system_mode" != "simplex" ];then
    config_net_mgmt
fi

config_net_data
config_ceph_osd
config_nova_local

if [ "$NTPSERVERS" != ""];then
    system ntp-modify ntpservers=$NTPSERVERS
fi

config_host_label