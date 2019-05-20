
# wget http://mirror.centos.org/centos/7/os/x86_64/Packages/usbutils-007-5.el7.x86_64.rpm

WORKDIR=$(dirname $(readlink -f $0))
CONF_FILE=$WORKDIR/nova_pci_pass.conf

restart_compute(){
    if [ ! -f "$WORKDIR/nova.conf_bak" ];then
        cp /etc/nova/nova.conf $WORKDIR/nova.conf_bak
    fi
    sudo cp $CONF_FILE /etc/nova/nova.conf
    NOVA=$(pgrep nova)
    sudo kill -9 $NOVA
    sudo service iptables stop
}

build_conf(){
    if [ ! -f "$CONF_FILE" ];then
        cp /etc/nova/nova.conf $CONF_FILE
        add_pci_alias
        modify_cpu_mode
    fi
}

add_pci_alias(){
    lsusb
    if [ $? -ne 0 ]; then
        sudo yum install -y $WORKDIR/usbutils-007-5.el7.x86_64.rpm
    fi
    lsusb -v 2>/dev/null | grep '^Bus\|iSerial'
    lspci -nn |grep USB 
    read -p "Input the vendor_id (front):" vendor_id
    read -p "Input the product_id (back):" product_id
    content="alias={\"vendor_id\":\"$vendor_id\",\"product_id\":\"$product_id\",\"device_type\":\"type-PCI\",\"name\":\"a1\"}"
    whitelist="passthrough_whitelist={\"product_id\":\"a12f\",\"vendor_id\":\"8086\"}"
    sed -i "/\[pci\]/a$content" $CONF_FILE
    sed -i "/\[pci\]/a$whitelist" $CONF_FILE
}

modify_cpu_mode(){
    sed -i "s/^cpu_mode=none/cpu_mode=host-model/g" $CONF_FILE
}

build_conf
restart_compute