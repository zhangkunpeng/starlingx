#! bin/bash

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