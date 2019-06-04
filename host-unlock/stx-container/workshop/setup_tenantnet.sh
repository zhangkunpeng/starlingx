export OS_CLOUD=openstack_helm
ADMINID=`openstack project list | grep admin | awk '{print $2}'`
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
 
neutron net-create --tenant-id ${ADMINID} --provider:network_type=vlan --provider:physical_network=${PHYSNET0} --provider:segmentation_id=10 --router:external ${EXTERNALNET}
neutron net-create --tenant-id ${ADMINID} --provider:network_type=vlan --provider:physical_network=${PHYSNET0} --provider:segmentation_id=400 ${PUBLICNET}
neutron net-create --tenant-id ${ADMINID} --provider:network_type=vlan --provider:physical_network=${PHYSNET1} --provider:segmentation_id=500 ${PRIVATENET}
neutron net-create --tenant-id ${ADMINID} ${INTERNALNET}
PUBLICNETID=`neutron net-list | grep ${PUBLICNET} | awk '{print $2}'`
PRIVATENETID=`neutron net-list | grep ${PRIVATENET} | awk '{print $2}'`
INTERNALNETID=`neutron net-list | grep ${INTERNALNET} | awk '{print $2}'`
EXTERNALNETID=`neutron net-list | grep ${EXTERNALNET} | awk '{print $2}'`
neutron subnet-create --tenant-id ${ADMINID} --name ${PUBLICSUBNET} ${PUBLICNET} 192.168.101.0/24
neutron subnet-create --tenant-id ${ADMINID} --name ${PRIVATESUBNET} ${PRIVATENET} 192.168.201.0/24
neutron subnet-create --tenant-id ${ADMINID} --name ${INTERNALSUBNET} --no-gateway  ${INTERNALNET} 10.10.0.0/24
neutron subnet-create --tenant-id ${ADMINID} --name ${EXTERNALSUBNET} --gateway 192.168.1.1 --disable-dhcp ${EXTERNALNET} 192.168.1.0/24
neutron router-create ${PUBLICROUTER}
neutron router-create ${PRIVATEROUTER}
PRIVATEROUTERID=`neutron router-list | grep ${PRIVATEROUTER} | awk '{print $2}'`
PUBLICROUTERID=`neutron router-list | grep ${PUBLICROUTER} | awk '{print $2}'`
neutron router-gateway-set --disable-snat ${PUBLICROUTERID} ${EXTERNALNETID}
neutron router-gateway-set --disable-snat ${PRIVATEROUTERID} ${EXTERNALNETID}
neutron router-interface-add ${PUBLICROUTER} ${PUBLICSUBNET}
neutron router-interface-add ${PRIVATEROUTER} ${PRIVATESUBNET}
