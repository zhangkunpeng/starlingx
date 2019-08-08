# Download yml files and update config.
#!/bin/sh

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/cinder_override.yml
system helm-override-update stx-openstack cinder openstack --values cinder-override.yml
echo "Cinder config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/glance_override.yml
system helm-override-update stx-openstack glance openstack --values glance-override.yml
echo "Glance config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/heat_override.yml
system helm-override-update stx-openstack heat openstack --values heat-override.yml
echo "Glance config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/ironic_override.yml
system helm-override-update stx-openstack ironic openstack --values ironic-override.yml
echo "Heat config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/keystone_override.yml
system helm-override-update stx-openstack keystone openstack --values keystone-override.yml
echo "Keystone config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/neutron_override.yml
system helm-override-update stx-openstack neutron openstack --values neutron-override.yml
echo "Neutron config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/nova_override.yml
system helm-override-update stx-openstack nova openstack --values nova-override.yml
echo "Nova config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/placement_override.yml
system helm-override-update stx-openstack placement openstack --values placement-override.yml
echo "Placement config has been updated."

