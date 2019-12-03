#/bin/bash

CMD=$1
glance_puppet_path=/usr/share/puppet/modules/openstack/manifests
work_path=$(dirname `readlink -f $0`)

if [ "$CMD" == "setup" ];then
    remote_host=$2
    if [ "$remote_host" == "" ];then
        echo "请输入适配层地址"
        exit 1
    fi
    cd $glance_puppet_path
    patch -p1 < $work_path/001_replace_glance.patch
    cat /etc/puppet/hieradata/global.yaml |grep "openstack::glance::params::remote_host"
    sed -i '/^openstack::glance::params::remote_host.*/d' /etc/puppet/hieradata/global.yaml
    echo "openstack::glance::params::remote_host: $remote_host" >> /etc/puppet/hieradata/global.yaml
    cd $work_path
elif [ "$CMD" == "rollback" ];then
    cd $glance_puppet_path
    patch -Rp1 < $work_path/001_replace_glance.patch
    sed -i '/^openstack::glance::params::remote_host.*/d' /etc/puppet/hieradata/global.yaml
    cd $work_path
else
    echo ""
    echo "$0 setup [remote glance server]      安装glance替换补丁"
    echo "$0 rollback                          回退glance替换补丁"
fi

