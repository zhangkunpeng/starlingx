# StarlingX 容器化部署流程

在新版的StarlingX中，已经没有了`sudo config_controller`，取而代之的是`ansible playbook`。
正常来说，跟着官方文档走是没有问题的。但是因为谷歌云被墙掉的缘故，我们需要修改一些`.yml`文件。
官方文档链接：
https://wiki.openstack.org/wiki/StarlingX/Containers/InstallationOnStandardStorage


---

### 用户名密码初始化
为了后面的命令方便，这里密码设置也是用的默认密码。
```
login: wrsroot
password: St8rlingX*
```

### 初始化网络
网络地址也是使用的文档中给出的默认的地址。
```
# sudo ifconfig enp2s1 10.10.10.3/24
# sudo ip route add default via 10.10.10.1 dev enp2s1
```
设置好之后，`ping 8.8.8.8` 来保证网络的连通性。


> 这里介绍两种方式来解决被墙掉的问题。
- 修改镜像源
- 使用代理
## 修改镜像源
解决镜像被墙掉的方法是将镜像源换成Azure。
将下面几处代码中所有的
- `k8s.gcr.io`替换为`gcr.azk8s.cn/google-containers`
- `gcr.io`替换为`gcr.azk8s.cn`
#### 第一处
文件路径
`/usr/share/ansible/stx-ansible/playbooks/bootstrap/roles/prepare-env/tasks/main.yml`
```
  - name: Set docker registries to default values if not specified
    set_fact:
      docker_registries:
        - k8s.gcr.io
        - gcr.io
        - quay.io
        - docker.io
    when: docker_registries is none
```
#### 第二处
文件路径
`/usr/share/ansible/stx-ansible/playbooks/bootstrap/roles/validate-config/tasks/main.yml`
```
- block:
  - set_fact:
      use_default_registries: true
      # Define these just in case we need them later
      default_k8s_registry: k8s.gcr.io
      default_gcr_registry: gcr.io
      default_quay_registry: quay.io
      default_docker_registry: docker.io
      default_no_proxy:
```
#### 第三处
文件路径
`/usr/share/ansible/stx-ansible/playbooks/bootstrap/roles/bringup-essential-services/vars/main.yml`
```
tiller_img: gcr.io/kubernetes-helm/tiller:v2.13.1
armada_img: quay.io/airshipit/armada:af8a9ffd0873c2fbc915794e235dbd357f2adab1
source_helm_bind_dir: /opt/cgcs/helm_charts
target_helm_bind_dir: /www/pages/helm_charts
```
---
### 修改helm repo源
除了上面的镜像源之外，helm repo 默认使用的源同样也是被墙掉的。
```
[root@kubernetes-1 ~]# helm repo list
NAME    URL                                             
stable  https://kubernetes-charts.storage.googleapis.com
local   http://127.0.0.1:8879/charts 
```
所以我们需要将其stable源给改掉，这里替换成阿里云的源。
文件路径：
`/usr/share/ansible/stx-ansible/playbooks/bootstrap/roles/bringup-essential-services/tasks/bringup_helm.yml`
在文件236行左右的位置，添加这些语句：
```
- name: remove stable repo
  command: helm repo remove stable
  become_user: wrsroot
  environment:
    KUBECONFIG: /etc/kubernetes/admin.conf
    HOME: /home/wrsroot

- name: helm repo add stable
  command: helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
  become_user: wrsroot
  environment:
    KUBECONFIG: /etc/kubernetes/admin.conf
    HOME: /home/wrsroot
```
---
至此，修改镜像源的工作就完成了。

## 使用代理
### docker配置
新建docker配置文件`/etc/systemd/system/docker.service.d/http-proxy.conf`,在这个文件中加入以下代码。
```
[Service]
Environment="HTTP_PROXY=http://172.16.30.31:3128"
Environment="NO_PROXY=localhost, 127.0.0.1, 192.168.204.2"
```
### 重启服务
之后必须重启服务docker服务，但是因为某些原因，重启docker服务会产生问题，这里建议直接重启。
```
# sudo reboot
```
### 验证
验证docker代理配置
```
# sudo systemctl show --property Environment docker 
```

### helm配置
使用环境变量来配置helm的配置
```
# export http_proxy="http://172.16.30.31:3128"
# export https_proxy="http://172.16.30.31:3128"
# export no_proxy="localhost,127.0.0.1,192.168.206.2"
```


----

使用上面的任意一种方法之后，就可以开始运行ansible-playbook了。

### 运行ansible-playbook
```
ansible-playbook /usr/share/ansible/stx-ansible/playbooks/bootstrap/bootstrap.yml
```