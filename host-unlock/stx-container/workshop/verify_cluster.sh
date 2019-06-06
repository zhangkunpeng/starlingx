

PASSWORD=""

while getopts "p:" opt; do
  case $opt in
    p)
      PASSWORD=$OPTARG
      echo  $PASSWORD
      ;;
    \?)
      echo "ERROR: Invalid option" 
      exit 1
      ;;
  esac
done

if [ -z "$PASSWORD" ];then
    echo "ERROR: Please input the admin password with '-p'"
    exit 1
fi

mkdir -p /etc/openstack
tee /etc/openstack/clouds.yaml << EOF
clouds:
  openstack_helm:
    region_name: RegionOne
    identity_api_version: 3
    auth:
      username: 'admin'
      password: '$PASSWORD'
      project_name: 'admin'
      project_domain_name: 'default'
      user_domain_name: 'default'
      auth_url: 'http://keystone.openstack.svc.cluster.local/v3'
EOF
 
export OS_CLOUD=openstack_helm
openstack endpoint list
