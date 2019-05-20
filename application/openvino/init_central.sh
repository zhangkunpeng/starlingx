#! bash

source /etc/nova/openrc

set_flavor(){
    openstack flavor show openvino
    if [ $? -ne 0 ]; then
        echo "cannot find openvino flavor"
        openstack flavor create --ram 8196 --vcpu 2 openvino
    fi
    openstack flavor set openvino --property "pci_passthrough:alias"="a1:1"
}

set_flavor