# Download yml files and update config.
#!/bin/sh

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/cinder_override.yml
system helm-override-update stx-openstack cinder openstack --values cinder-override.yml

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/glance_override.yml
system helm-override-update stx-openstack glance openstack --values glance-override.yml

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/heat_override.yml
system helm-override-update stx-openstack heat openstack --values heat-override.yml

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/ironic_override.yml
system helm-override-update stx-openstack ironic openstack --values ironic-override.yml

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/keystone_override.yml
system helm-override-update stx-openstack keystone openstack --values keystone-override.yml

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/neutron_override.yml
system helm-override-update stx-openstack neutron openstack --values neutron-override.yml

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/nova_override.yml
system helm-override-update stx-openstack nova openstack --values nova-override.yml

sudo wget -P /home/$USER/ https://github.com/zhangkunpeng/starlingx/blob/master/deployment/stx-container/deployment_yml/placement_override.yml
system helm-override-update stx-openstack placement openstack --values placement-override.yml

