#! /bin/bash

# 用于替换starlingx的keystone

ORIGIN_IP="http://10.2.52.2"
CURRENT_IP="http://10.2.51.250"

SERVICE=""

usage() {
    echo "$0 [-h] [-a] [-s <service name>] [-f <file path>] [-d <dir path>]"
    echo ""
    echo "Options:"
    echo "  -a: all services"
    echo "  -s: service example:nova|sysinv|dcmanager|dcorch|fm|glance|"
    echo "                      neutron|patching|cinder|ceilometer|vim|"
    echo "                      aodh|heat|panko|goncchi|smapi"
    echo "  -f: file path"
    echo "  -d: dir path"
    echo ""
}


replace_file() {
    filepath=$(readlink -f "$1")
    if [[ -z ${filepath} ]]; then
        echo "File is not exist. filepath: ${filepath}"
    else
        sed -i "s?^auth_url=${ORIGIN_IP}:5000?auth_url=${CURRENT_IP}:5000?g" ${filepath}
        sed -i "s?^auth_uri=${ORIGIN_IP}:5000?auth_uri=${CURRENT_IP}:5000?g" ${filepath}
        sed -i "s?^auth_url = ${ORIGIN_IP}:5000?auth_url=${CURRENT_IP}:5000?g" ${filepath}
        sed -i "s?^auth_uri = ${ORIGIN_IP}:5000?auth_uri=${CURRENT_IP}:5000?g" ${filepath}
        cat ${filepath} |grep auth_ur
    fi
}

replace_dir() {
    dirpath=$(readlink -f "$1")
    if [[ ! -d ${dirpath} ]]; then
        echo "Dir is not exist. dirpath: ${dirpath}"
    else
        sed -i "s?^auth_url=${ORIGIN_IP}:5000?auth_url=${CURRENT_IP}:5000?g" `grep ${ORIGIN_IP} -rl ${dirpath}`
        sed -i "s?^auth_uri=${ORIGIN_IP}:5000?auth_uri=${CURRENT_IP}:5000?g" `grep ${ORIGIN_IP} -rl ${dirpath}`
        sed -i "s?^auth_url = ${ORIGIN_IP}:5000?auth_url=${CURRENT_IP}:5000?g" `grep ${ORIGIN_IP} -rl ${dirpath}`
        sed -i "s?^auth_uri = ${ORIGIN_IP}:5000?auth_uri=${CURRENT_IP}:5000?g" `grep ${ORIGIN_IP} -rl ${dirpath}`
        grep ${CURRENT_IP}:5000 -rn ${dirpath}
    fi
}


replace_service() {
    case "${SERVICE}" in
        nova|sysinv|dcmanager|dcorch|fm|glance|neutron|patching|cinder|ceilometer|vim|aodh|heat|panko|goncchi)
            replace_dir "/etc/${SERVICE}/"
            ;;
        patch)
            replace_dir "/etc/patching/"
            ;;
        smapi)
            replace_dir "/etc/sm-api/"
            ;;
        *)
            echo "error"
    esac
}

while getopts "s:f:d:a" o; do
    case "${o}" in
        s)
            SERVICE="$OPTARG"
            replace_service
            ;;
        f)
            replace_file $OPTARG
            ;;
        d)
            replace_dir $OPTARG
            ;;
        a)
            replace_dir "/etc/ "
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done