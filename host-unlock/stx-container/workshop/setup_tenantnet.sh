export OS_CLOUD=openstack_helm

PHYSNET0='physnet0'
PHYSNET1='physnet1'
PUBLICNET='public-net0'
PRIVATENET='private-net0'
INTERNALNET='internal-net0'
EXTERNALNET='external-net0'
PUBLICSUBNET='public-subnet0'
PRIVATESUBNET='private-subnet0'
INTERNALSUBNET='internal-subnet0'
EXTERNALSUBNET='external-subnet0'
PUBLICROUTER='public-router0'
PRIVATEROUTER='private-router0'

openstack network create --project ${ADMINID} --provider-network-type=vlan --provider-physical-network=${PHYSNET0} --provider-segment=10 --share --external ${EXTERNALNET}
openstack network create --project ${ADMINID} --provider-network-type=vlan --provider-physical-network=${PHYSNET0} --provider-segment=400 ${PUBLICNET}
openstack network create --project ${ADMINID} --provider-network-type=vlan --provider-physical-network=${PHYSNET1} --provider-segment=500 ${PRIVATENET}
openstack network create --project ${ADMINID} ${INTERNALNET}
PUBLICNETID=`openstack network list | grep ${PUBLICNET} | awk '{print $2}'`
PRIVATENETID=`openstack network list | grep ${PRIVATENET} | awk '{print $2}'`
INTERNALNETID=`openstack network list | grep ${INTERNALNET} | awk '{print $2}'`
EXTERNALNETID=`openstack network list | grep ${EXTERNALNET} | awk '{print $2}'`
openstack subnet create --project ${ADMINID} ${PUBLICSUBNET} --network ${PUBLICNET} --subnet-range 192.168.101.0/24
openstack subnet create --project ${ADMINID} ${PRIVATESUBNET} --network ${PRIVATENET} --subnet-range 192.168.201.0/24
openstack subnet create --project ${ADMINID} ${INTERNALSUBNET} --gateway none --network ${INTERNALNET} --subnet-range 10.1.1.0/24
openstack subnet create --project ${ADMINID} ${EXTERNALSUBNET} --gateway 192.168.1.1 --no-dhcp --network ${EXTERNALNET} --subnet-range 192.168.51.0/24 --ip-version 4
openstack router create ${PUBLICROUTER}
openstack router create ${PRIVATEROUTER}
PRIVATEROUTERID=`openstack router list | grep ${PRIVATEROUTER} | awk '{print $2}'`
PUBLICROUTERID=`openstack router list | grep ${PUBLICROUTER} | awk '{print $2}'`
openstack router set ${PUBLICROUTER} --external-gateway ${EXTERNALNETID} --disable-snat
openstack router set ${PRIVATEROUTER} --external-gateway ${EXTERNALNETID} --disable-snat
openstack router add subnet ${PUBLICROUTER} ${PUBLICSUBNET}
openstack router add subnet ${PRIVATEROUTER} ${PRIVATESUBNET}
