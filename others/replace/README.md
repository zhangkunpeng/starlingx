## 替换Glance服务

#### glance服务配置

1. 修改远端glance配置文件，主要修改认证url、认证用户名密码、项目名称等认证相关信息(参考StarlingX中glance配置文件)
2. 在2个控制节点上执行一键替换脚本： sudo sh replace_glance.sh setup <remote ip>

#### 配置生效

1. 在备用节点上执行 `/etc/init.d/controller_config start`，等待命令成功
2. 在active的节点上执行 `source /etc/nova/openrc; system host-swact <active controller>`
3. 等待备用节点active后，重复执行1、2步骤，使得原本active的节点配置生效

## 替换keystone服务

#### keystone配置

1. 修改远端keystone的admin密码和StarlingX的一样
2. 修改远端keystone的5000端口为admin，重启远端keystone
3. 修改脚本update_dist_keystone.sh中的认证URL和密码
4. 在active的控制节点上执行脚本`bash update_dist_keystone.sh`,等待脚本执行完毕
5. 分别在2个控制节点上执行脚本`sudo sh replace_keystone.sh`

#### 配置生效

1. 在备用节点上执行 `/etc/init.d/controller_config start`，等待命令成功
2. 在active的节点上执行 `source /etc/nova/openrc; system host-swact <active controller>`
3. 等待备用节点active后，重复执行1、2步骤，使得原本active的节点配置生效
