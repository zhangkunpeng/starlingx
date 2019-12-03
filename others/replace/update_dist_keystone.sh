#! bin/bash

WORKDIR=$(cd "$(dirname "$0")";pwd)

export OS_REGION_NAME=RegionOne
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_KEYSTONE_REGION_NAME=RegionOne
export OS_IDENTITY_API_VERSION=3
export OS_ENDPOINT_TYPE=publicURL
export OS_INTERFACE=public
export OS_AUTH_TYPE=password

STX_OS_AUTH_URL=http://192.168.204.2:5000/v3
STX_OS_PASSWORD=99cloud@SH

DIST_OS_AUTH_URL=http://192.168.204.2:5000/v3
DIST_OS_PASSWORD=99cloud@SH

switch_dist_keytone(){
    export OS_USERNAME=admin
    export OS_PROJECT_NAME=admin
    export OS_AUTH_URL=$DIST_OS_AUTH_URL
    export OS_PASSWORD=$DIST_OS_PASSWORD
}

switch_stx_keystone(){
    export OS_USERNAME=admin
    export OS_PROJECT_NAME=admin
    export OS_AUTH_URL=$STX_OS_AUTH_URL
    export OS_PASSWORD=$STX_OS_PASSWORD
}

error_exit(){
    if [ $? -ne 0 ];then
        echo $1
        exit 1
    fi
}

## insert users

create_project(){
    local project=$1
    switch_dist_keytone
    openstack project show $project
    if [ $? -ne 0 ];then
        openstack project create --domain $OS_USER_DOMAIN_NAME --description "starlingx services" --enable $project
        error_exit "create project $project failed ..."
    fi
}

check_user_in_dist(){
    local USERNAME=$1
    local PASSWORD=$2
    local project=$3
    export OS_USERNAME=$USERNAME
    export OS_PROJECT_NAME=$project
    export OS_PASSWORD=$PASSWORD
    export OS_AUTH_URL=$DIST_OS_AUTH_URL
    openstack user show $USERNAME
    if [ $? -eq 0 ];then
        echo "user [$USERNAME] is ok ..."
        return 0
    else
        echo "user [$USERNAME] is incorrect, need to recreate it ..."
        return 1
    fi
}

set_admin_password(){
    echo "set admin password ..."
    if [ $STX_OS_PASSWORD = $DIST_OS_PASSWORD ];then
        echo "dist keystone admin password is same as starlingx ..."
        return 0
    fi
    switch_dist_keytone
    openstack user password set --password $STX_OS_PASSWORD --original-password $DIST_OS_PASSWORD
    if [ $? -ne 0 ];then
        echo "dist keystone admin password set failed ..."
        exit 1
    fi 
    echo "dist keystone admin password set success ..."
}

create_user(){
    local USERNAME=$1
    local project=$2
    local PASSWORD=$(keyring get $USERNAME $project)
    if [ "$USERNAME" == "admin" ];then
        set_admin_password
    elif [ ! -n "$PASSWORD" ]; then
        echo "Can not get $USERNAME password ..."
    else
        check_user_in_dist $USERNAME $PASSWORD $project
        if [ $? -ne 0 ];then
            switch_dist_keytone
            openstack user show $USERNAME
            if [ $? -eq 0 ]; then
                openstack user delete $USERNAME
                error_exit "delete user $USERNAME failed ..."
            fi
            openstack user create --domain $OS_USER_DOMAIN_NAME --project-domain $OS_PROJECT_DOMAIN_NAME --project $project --password $PASSWORD --email $USERNAME@starlingx $USERNAME
            error_exit "create user [$USERNAME] failed."
            openstack role add --project $project --user $USERNAME admin
            #check_user_in_dist $USERNAME $PASSWORD $project
            error_exit "check user [$USERNAME] failed. Unknow problems occured"
            echo "create user $USERNAME is ok ..."
        fi
    fi
}

update_users_in_dist(){
    local project=$1
    echo "Get all users in project $project of starlingx ..."
    switch_stx_keystone
    OUL=/tmp/openstack-user-list-$project
    openstack user list --project $project > $OUL
    local Users=($(cat ${OUL} |grep -v Name | awk '{print $4}'))
    for(( j=0;j<${#Users[@]};j++)) do
        #${#array[@]}获取数组长度用于循环
        create_user ${Users[j]} $project
    done
}

update_projects_in_dist(){
    echo "Get all projects of starlingx ..."
    switch_stx_keystone
    OPL=/tmp/openstack-project-list
    openstack project list > $OPL
    cat ${OPL}
    local Projects=($(cat ${OPL} |grep -v Name | awk '{print $4}'))
    for(( i=0;i<${#Projects[@]};i++)) do
        #${#array[@]}获取数组长度用于循环
        echo ${Projects[i]}
        create_project ${Projects[i]}
        update_users_in_dist ${Projects[i]}
    done
}

#### insert endpoints

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
    if [ "$region" == "RegionOne" ] && [ "$service" == "keystone" ];then
        return
    fi
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

create_role(){
    local RoleName=$1
    switch_dist_keytone
    echo "check region $RoleName in external keystone"
    openstack role show $RoleName
    if [ $? -ne 0 ]; then
        openstack role create $RoleName
        error_exit "Region $RoleName create failed."
    fi
    echo "Role $RoleName is ok ..."
}

update_roles_in_dist(){
    echo "Get all roles of starlingx ..."
    switch_stx_keystone
    ORL=/tmp/openstack-role-list
    openstack role list > $ORL
    local Roles=($(cat ${ORL} |grep -v Name | awk '{print $4}'))
    for(( i=0;i<${#Roles[@]};i++)) do
        #${#array[@]}获取数组长度用于循环
        #echo ${ServiceNames[i]},${ServiceTypes[i]};
        create_role ${Regions[i]}
    done;
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


### main 
update_roles_in_dist
update_projects_in_dist

update_regions_in_dist
update_services_in_dist
update_endpoints_in_dist

exit 0
