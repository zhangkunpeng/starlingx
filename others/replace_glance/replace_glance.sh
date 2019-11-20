#/bin/bash

CMD=$1
glance_sysinv_path=/usr/lib64/python2.7/site-packages/sysinv/puppet
glance_puppet_path=/usr/share/puppet/modules/openstack/manifests
work_patch=$(dirname `readlink -f $0`)

if [ "$CMD" == "setup" ];then
    remote_host=$2
    if [ "$remote_host" == "" ];then
        echo "请输入适配层地址"
    fi
    cd $glance_sysinv_path
    patch -p1 ./glance_sysinv.patch
    cd $glance_puppet_path
    patch -p1 ./glance_puppet.patch
    cat /etc/puppet/hieradata/global.yaml |grep "openstack::glance::params::remote_host"
    sed -i '/^openstack::glance::params::remote_host.*/d' /etc/puppet/hieradata/global.yaml
    echo "openstack::glance::params::remote_host: $remote_host" >> /etc/puppet/hieradata/global.yaml
    cd $work_patch
elif [ "$CMD" == "rollback" ];then
    cd $glance_sysinv_path
    patch -Rp1 ./glance_sysinv.patch
    cd $glance_puppet_path
    patch -Rp1 ./glance_puppet.patch
    sed -i '/^openstack::glance::params::remote_host.*/d' /etc/puppet/hieradata/global.yaml
    cd $work_patch
else
    echo ""
    echo "$0 setup [remote glance server]      安装glance替换补丁"
    echo "$0 rollback                          回退glance替换补丁"
fi
