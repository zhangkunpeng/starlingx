# 资源需求


最低要求 | All-in-one | controller | compute | storage
---|---|---|---|---
CPU | 16核 | 16核 | 16核 | 16核
内存 | 32G | 32G | 32G | 32G
硬盘 | 2块500G | 1块500G | 2块500G | 2块500G
网卡 | 2个/3个 | 2个 | 2个 | 1个

# 安装部署(在线/离线)

安装步骤标题后面带有（在线）表示是在线安装必选，
带有（离线）表示是离线安装必选
## 安装操作系统

1. 下载离线安装文件（离线）
- 百度网盘
```
链接：https://pan.baidu.com/s/1dIufLXBfFjDt8mzi_DLtKA 
提取码：gpeg 
由于网盘文件最大为4G,从stx-images.zip,自行提取stx-images-r2.0.tar.gz文件
```
- 公司内网从 http://172.16.130.131/stx-r2.0/ 下载

2. 使用bootimage.iso镜像个第一台主机安装操作系统
```
// 写入U盘命令(mac)
// 查询所有硬盘
diskutil list
// 取消挂载U盘
diskutil unmountDisk /dev/disk2
// 写入系统
sudo dd if=***.iso of=/dev/rdisk2 bs=1m;sync
// 弹出U盘
diskutil eject /dev/disk2
```
3. 根据部署要求选择安装选项

- 第一个菜单配置项：
    - 单节点和双节点安装，选择 All-in-one Controller Configuration
    - 标准部署（控制计算分离的多节点部署），选择Standard Controller Configuration
- 第二个菜单配置项：
    - 在终端安装的，选择 Serial Console
    - 通过BMC、虚拟管理器GUI或者外接显示器的，选择 Graphical Console
- 第三个菜单配置项（如果有）：
    - 选择 Standard Security Profile

## 系统引导

1. 首次登陆，强制修改密码(sysadmin/sysadmin)
```
Login: sysadmin
Password: sysadmin
Changing password for sysadmin.
(current) UNIX Password: sysadmin
New Password:
(repeat) New Password:
```
2. 配置主机网络
```
sudo ip address add <IP-ADDRESS>/<SUBNET-LENGTH> dev <PORT>
sudo ip link set up dev <PORT>
sudo ip route add default via <GATEWAY-IP-ADDRESS> dev <PORT>
# 在线部署需要能连接互联网
ping 8.8.8.8
```
3. 拷贝离线文件到主机 
```
# 系统安装后根目录的空间比较小，需要先创建个临时的分区存放系统需要的容器镜像文件
sudo fdisk /dev/sdb
# 创建最少50G大小的分区，分区创建不收省略
# 挂载分区
mkdir -p /home/sysadmin/images
sudo mkfs.ext4 /dev/sdb1
sudo mount /dev/sdb1 /home/sysadmin/images
sudo chmod 755 /home/sysadmin/images

# 拷贝镜像文件(在自己的主机上执行)
scp stx-images-r2.0.tar.gz sysadmin@<ip>:~/images/
scp stx-openstack-1.0-17-centos-stable-latest.tgz sysadmin@<ip>:~/

# 解压镜像包
tar -xvf stx-images-r2.0.tar.gz
# 确认tar包在images/目录下，如下所示
ls ~/images/
armada:dd2e56c473549fd16f94212b553ed58c48d1f51b-ubuntu_bionic.tar  pause:3.1.tar
ceph-config-helper:v1.10.3.tar                                     push_images_into_stx_registry.sh
ceph-daemon:latest.tar                                             rabbitmq:3.7.13-management.tar
cni:v3.6.2.tar                                                     rabbitmq:3.7.13.tar
coredns:1.2.6.tar                                                  rabbitmq:3.7-management.tar
defaultbackend:1.0.tar                                             rabbitmq-exporter:v0.21.0.tar
docker:17.07.0.tar                                                 rbd-provisioner:v2.1.1-k8s1.11.tar
k8s-cni-sriov:master-centos-stable-latest.tar                      stx-aodh:rc-2.0-centos-stable-latest.tar
k8s-cni-sriov:rc-2.0-centos-stable-latest.tar                      stx-barbican:rc-2.0-centos-stable-latest.tar
k8s-plugins-sriov-network-device:master-centos-stable-latest.tar   stx-ceilometer:rc-2.0-centos-stable-latest.tar
k8s-plugins-sriov-network-device:rc-2.0-centos-stable-latest.tar   stx-cinder:rc-2.0-centos-stable-latest.tar
keepalived:1.4.5.tar                                               stx-glance:rc-2.0-centos-stable-latest.tar
kube-apiserver:v1.13.5.tar                                         stx-gnocchi:rc-2.0-centos-stable-latest.tar
kube-controller-manager:v1.13.5.tar                                stx-heat:rc-2.0-centos-stable-latest.tar
kube-controllers:v3.6.2.tar                                        stx-horizon:rc-2.0-centos-stable-latest.tar
kube-proxy:v1.13.5.tar                                             stx-ironic:rc-2.0-centos-stable-latest.tar
kubernetes-dashboard-amd64:v1.10.1.tar                             stx-keystone-api-proxy:rc-2.0-centos-stable-latest.tar
kubernetes-entrypoint:v0.3.1.tar                                   stx-keystone:rc-2.0-centos-stable-latest.tar
kube-scheduler:v1.13.5.tar                                         stx-libvirt:rc-2.0-centos-stable-latest.tar
mariadb:10.2.13.tar                                                stx-mariadb:rc-2.0-centos-stable-latest.tar
mariadb:10.2.18.tar                                                stx-neutron:rc-2.0-centos-stable-latest.tar
memcached:1.5.5.tar                                                stx-nova-api-proxy:rc-2.0-centos-stable-latest.tar
memcached-exporter:v0.4.1.tar                                      stx-nova:rc-2.0-centos-stable-latest.tar
multus:v3.2.tar                                                    stx-ovs:rc-2.0-centos-stable-latest.tar
mysqld-exporter:v0.10.0.tar                                        stx-panko:rc-2.0-centos-stable-latest.tar
neutron:ocata.tar                                                  stx-placement:rc-2.0-centos-stable-latest.tar
nginx:1.13.3.tar                                                   tiller:v2.13.1.tar
nginx-ingress-controller:0.23.0.tar                                ubuntu-source-nova-novncproxy:ocata.tar
nginx-ingress-controller:0.9.0.tar                                 xrally-openstack:1.3.0.tar
node:v3.6.2.tar
```

4. 创建系统引导配置文件，执行bootstrap
```
cd ~
cat <<EOF > localhost.yml
# 单节点填写simplex，双节点或多节点填写duplex
system_mode: simplex
timezone: Asia/Shanghai

dns_servers:
  - 8.8.8.8
  - 8.8.4.4

external_oam_subnet: 10.10.10.0/24
external_oam_gateway_address: 10.10.10.1
external_oam_floating_address: 10.10.10.2
external_oam_node_0_address: 10.10.10.3
external_oam_node_1_address: 10.10.10.4

admin_username: admin
# 自定义集群访问密码
admin_password: Starlingx@1
# 主机root权限密码
ansible_become_pass: <sysadmin-password>

# 离线安装配置
docker_images_archive_source: /home/sysadmin/images
# 另外一种离线安装的方式是通过自己搭建的私有仓库
#docker_registries:
#  unified:
#    url: <private-registry>
#is_secure_registry: False
EOF

ansible-playbook /usr/share/ansible/stx-ansible/playbooks/bootstrap/bootstrap.yml
```

5. 把镜像上传到StarlingX镜像仓库
```
# 执行push脚本
cd ~
cp -rf ~/images/push_images_into_stx_registry.sh ~/
sudo bash push_images_into_stx_registry.sh
# 提示登录StarlingX集群镜像仓库，输入集群用户名和密码(参考localhost.yml)
Username:
Password:
```

## 配置StarlingX

- 可以参考官方教程：https://docs.starlingx.io/deploy_install_guides/index.htmlz

- 或者通过配置脚本
```
# 在能连接互联网的主机上下载脚本文件，并拷贝到StarlingX主机
wget https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/host-unlock/stx-2.0/unluck-host.sh
scp unlock-host.sh sysadmin@<ip>:~/

# 执行unlock
sh unlock-host.sh
# 如果是带有专有存储节点的，加上参数 -c storage
# 简单的交互式方式进行配置
# 配置脚本只提供简单的必要配置，其他的配置可参与社区讨论
```
