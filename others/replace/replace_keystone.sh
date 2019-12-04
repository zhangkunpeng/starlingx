#/bin/bash

CMD=$1
puppet_path=/usr/share/puppet/modules/openstack/manifests
work_path=$(dirname `readlink -f $0`)
patch_path=$work_path/002_replace_keystone.patch

if [ "$CMD" == "setup" ];then
    remote_host=$2
    if [ "$remote_host" == "" ];then
        echo "请输入适配层地址"
        exit 1
    fi
    cd $puppet_path
    patch -p1 < $patch_path
    cat /etc/puppet/hieradata/global.yaml |grep "openstack::keystone::params::remote_host"
    sed -i '/^openstack::keystone::params::remote_host.*/d' /etc/puppet/hieradata/global.yaml
    echo "openstack::keystone::params::remote_host: $remote_host" >> /etc/puppet/hieradata/global.yaml
    sed -i 's/BIND_PUBLIC=$PUBLIC_BIND_ADDR:5000/BIND_PUBLIC=127.0.0.1:5000/' /usr/bin/keystone-all
    cd $work_path
elif [ "$CMD" == "rollback" ];then
    cd $puppet_path
    patch -Rp1 < $patch_path
    sed -i '/^openstack::keystone::params::remote_host.*/d' /etc/puppet/hieradata/global.yaml
    sed -i 's/BIND_PUBLIC=127.0.0.1:5000/BIND_PUBLIC=$PUBLIC_BIND_ADDR:5000/' /usr/bin/keystone-all
    cd $work_path
else
    echo ""
    echo "$0 setup [remote host IP]              安装keystone替换补丁"
    echo "$0 rollback                            回退keystone替换补丁"
fi

