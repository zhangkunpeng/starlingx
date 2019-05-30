source /etc/platform/openrc
OAM_IF=enp2s1
MGMT_IF=enp2s2
system host-if-modify controller-0 lo -c none
system host-if-modify controller-0 $OAM_IF --networks oam -c platform
system host-if-modify controller-0 $MGMT_IF -c platform --networks mgmt
system host-if-modify controller-0 $MGMT_IF -c platform --networks cluster-host