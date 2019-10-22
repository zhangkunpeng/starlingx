
source ~/openstack_rc
ADMINID=`openstack project list | grep admin | awk '{print $2}'`
PHYSNET0='physnet0'
PUBLICNET='public-net0'
PUBLICSUBNET='public-subnet0'

openstack network segment range create ${PHYSNET0}-a \
    --network-type vlan --physical-network ${PHYSNET0} \
    --minimum 100 --maximum 499 --shared

openstack network create --project ${ADMINID} \
    --provider-network-type=vlan \
    --provider-physical-network=${PHYSNET0} \
    --provider-segment=400 ${PUBLICNET}

openstack subnet create --project ${ADMINID} ${PUBLICSUBNET} --network ${PUBLICNET} --subnet-range 192.168.101.0/24