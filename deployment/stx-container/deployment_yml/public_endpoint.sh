# Download yml files and update config.
#!/bin/sh

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/cinder_override.yml
system helm-override-update stx-openstack cinder openstack --values cinder_override.yml
echo "Cinder config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/glance_override.yml
system helm-override-update stx-openstack glance openstack --values glance_override.yml
echo "Glance config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/heat_override.yml
system helm-override-update stx-openstack heat openstack --values heat_override.yml
echo "Glance config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/ironic_override.yml
system helm-override-update stx-openstack ironic openstack --values ironic_override.yml
echo "Heat config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/keystone_override.yml
system helm-override-update stx-openstack keystone openstack --values keystone_override.yml
echo "Keystone config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/neutron_override.yml
system helm-override-update stx-openstack neutron openstack --values neutron_override.yml
echo "Neutron config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/nova_override.yml
system helm-override-update stx-openstack nova openstack --values nova_override.yml
echo "Nova config has been updated."

sudo wget -P /home/$USER/ https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/deployment/stx-container/deployment_yml/placement_override.yml
system helm-override-update stx-openstack placement openstack --values placement_override.yml
echo "Placement config has been updated."

