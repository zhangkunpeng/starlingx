#! /bin/bash

# 用于在keystone上新增用户,脚本必须在starlingx控制节点上运行

source openrc

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
        return
    fi
    if [ ! -n "$PASSWORD" ]; then
        echo "Can not get $USERNAME password ..."
        return
    fi
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
        check_user_in_dist $USERNAME $PASSWORD $project
        error_exit "check user [$USERNAME] failed. Unknow problems occured"
        echo "create user $USERNAME is ok ..."
    fi
}

update_users_in_dist(){
    local project=$1
    echo "Get all users in project $project of starlingx ..."
    switch_stx_keystone
    OUL=/tmp/openstack-user-list-$project
    openstack user list --project $project > $OUL
    local Users=($(cat ${OUL} |grep -v Name | awk '{print $4}'))
    for(( i=0;i<${#Users[@]};i++)) do
        #${#array[@]}获取数组长度用于循环
        create_user ${Users[i]} $project
    done;
}

update_projects_in_dist(){
    echo "Get all projects of starlingx ..."
    switch_stx_keystone
    OPL=/tmp/openstack-project-list
    openstack project list > $OPL
    local Projects=($(cat ${OPL} |grep -v Name | awk '{print $4}'))
    for(( i=0;i<${#Projects[@]};i++)) do
        #${#array[@]}获取数组长度用于循环
        create_project ${Projects[i]}
        update_users_in_dist ${Projects[i]}
    done;
}

update_projects_in_dist
exit 0