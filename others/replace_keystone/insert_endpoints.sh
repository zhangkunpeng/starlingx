#! bin/bash

WORKDIR=$(cd "$(dirname "$0")";pwd)
RCFILE=$WORKDIR/openrc.sh
if [ ! -f "$RCFILE" ]; then
    echo "rc file is not exist ..."
    exit 1
fi

source $RCFILE

create_service(){
    local Name=$1
    local Type=$2
    switch_dist_keytone
    echo "check service $Name in external keystone..."
    openstack service show $Name
    if [ $? -ne 0 ]; then
        openstack service create --name $Name $Type
        error_exit "Service $Name - $Type create failed."
    fi
    echo "Service $Name - $Type is ok ..."
}

create_endpoint(){
    local region=$1
    local service=$2
    local interface=$3
    local url=$4
    switch_dist_keytone
    echo "---> region $region，service $service,interface $interface,url $url"
    uuid=$(openstack endpoint list --region $region --service $service |grep $interface | awk '{print $2}')
    if [ -n "$uuid" ]; then
        #echo $service $interface uuid: $uuid
        openstack endpoint set --url $url $uuid
        error_exit "set endpoint $service $interface failed..."
    else
        #echo $service $interface uuid: null
        openstack endpoint create --region $region $service $interface $url
        error_exit "create endpoint $service $interface failed..."
    fi
    echo "endpoint $region $service $interface is ok ..."
}

create_region(){
    local RegionName=$1
    switch_dist_keytone
    echo "check region $RegionName in external keystone"
    openstack region show $RegionName
    if [ $? -ne 0 ]; then
        openstack region create $RegionName
        error_exit "Region $RegionName create failed."
    fi
    echo "Region $RegionName is ok ..."
}

update_regions_in_dist(){
    echo "Get all regions of starlingx ..."
    switch_stx_keystone
    ORL=/tmp/openstack-region-list
    openstack region list > $ORL
    local Regions=($(cat ${ORL} |grep -v Description | awk '{print $2}'))
    for(( i=0;i<${#Regions[@]};i++)) do
        #${#array[@]}获取数组长度用于循环
        #echo ${ServiceNames[i]},${ServiceTypes[i]};
        create_region ${Regions[i]}
    done;
}

update_services_in_dist(){
    echo "Get all services of starlingx ..."
    switch_stx_keystone
    OSL=/tmp/openstack-service-list
    openstack service list > ${OSL}
    local ServiceNames=($(cat ${OSL} |grep -v Name |awk '{print $4}'))
    local ServiceTypes=($(cat ${OSL} |grep -v Type |awk '{print $6}'))

    for(( i=0;i<${#ServiceNames[@]};i++)) do
        #${#array[@]}获取数组长度用于循环
        #echo ${ServiceNames[i]},${ServiceTypes[i]};
        create_service ${ServiceNames[i]} ${ServiceTypes[i]}
    done;
}

update_endpoints_in_dist(){
    echo "Get all endpoints of starlingx ..."
    switch_stx_keystone
    OEL=/tmp/openstack-endpoint-list
    openstack endpoint list > ${OEL}
    local Regions=($(cat ${OEL} |grep  http: | awk '{print $4}'))
    local ServiceNames=($(cat ${OEL} |grep  http: | awk '{print $6}'))
    local ServiceTypes=($(cat ${OEL} |grep  http: | awk '{print $8}'))
    local Interfaces=($(cat ${OEL} |grep  http: | awk '{print $12}'))
    local URLs=($(cat ${OEL} |grep  http: | awk '{print $14}'))

    for(( i=0;i<${#ServiceNames[@]};i++)) do
        #${#array[@]}获取数组长度用于循环
        #echo ${ServiceNames[i]},${ServiceTypes[i]};
        create_endpoint ${Regions[i]} ${ServiceNames[i]} ${Interfaces[i]} ${URLs[i]}
    done;
}

update_regions_in_dist
update_services_in_dist
update_endpoints_in_dist

exit 0
