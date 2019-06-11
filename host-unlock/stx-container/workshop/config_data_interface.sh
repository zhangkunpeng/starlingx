DATA0IF=eth1000
DATA1IF=eth1001
export COMPUTE=controller-0
PHYSNET0='physnet0'
PHYSNET1='physnet1'
SPL=/tmp/tmp-system-port-list
SPIL=/tmp/tmp-system-host-if-list
source /etc/platform/openrc
system host-port-list ${COMPUTE} --nowrap > ${SPL}
system host-if-list -a ${COMPUTE} --nowrap > ${SPIL}
DATA0PCIADDR=$(cat $SPL | grep $DATA0IF |awk '{print $8}')
DATA1PCIADDR=$(cat $SPL | grep $DATA1IF |awk '{print $8}')
DATA0PORTUUID=$(cat $SPL | grep ${DATA0PCIADDR} | awk '{print $2}')
DATA1PORTUUID=$(cat $SPL | grep ${DATA1PCIADDR} | awk '{print $2}')
DATA0PORTNAME=$(cat $SPL | grep ${DATA0PCIADDR} | awk '{print $4}')
DATA1PORTNAME=$(cat  $SPL | grep ${DATA1PCIADDR} | awk '{print $4}')
DATA0IFUUID=$(cat $SPIL | awk -v DATA0PORTNAME=$DATA0PORTNAME '($12 ~ DATA0PORTNAME) {print $2}')
DATA1IFUUID=$(cat $SPIL | awk -v DATA1PORTNAME=$DATA1PORTNAME '($12 ~ DATA1PORTNAME) {print $2}')

# configure the datanetworks in sysinv, prior to referencing it in the 'system host-if-modify command'
system datanetwork-add ${PHYSNET0} vlan
system datanetwork-add ${PHYSNET1} vlan

# the host-if-modify '-p' flag is deprecated in favor of  the '-d' flag for assignment of datanetworks.
system host-if-modify -m 1500 -n data0 -d ${PHYSNET0} -c data ${COMPUTE} ${DATA0IFUUID}
system host-if-modify -m 1500 -n data1 -d ${PHYSNET1} -c data ${COMPUTE} ${DATA1IFUUID}
