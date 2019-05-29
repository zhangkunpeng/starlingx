# StarlingX 容器化部署流程

在新版的StarlingX中，已经没有了`sudo config_controller`，取而代之的是`ansible playbook`。
正常来说，跟着官方文档走是没有问题的。但是因为谷歌云被墙掉的缘故，我们需要修改一些`.yml`文件。
官方文档链接：
https://wiki.openstack.org/wiki/StarlingX/Containers/InstallationOnStandardStorage


---

## 用户名密码初始化
为了后面的命令方便，这里密码设置也是用的默认密码。
```
login: wrsroot
password: St8rlingX*
```

## 初始化网络
网络地址也是使用的文档中给出的默认的地址。
```
# sudo ifconfig enp2s1 10.10.10.3/24
# sudo ip routes add default via 10.10.10.1 dev enp2s1
```
设置好之后，`ping 8.8.8.8` 来保证网络的连通性。

## 修改镜像源
将下面几处代码中所有的
- `k8s.gcr.io`替换为`gcr.azk8s.cn/google-containers`
- `gcr.io`替换为`gcr.azk8s.cn`
### 第一处
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
### 第二处
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
### 第三处
文件路径
`/usr/share/ansible/stx-ansible/playbooks/bootstrap/roles/bringup-essential-services/vars/main.yml`
```
tiller_img: gcr.io/kubernetes-helm/tiller:v2.13.1
armada_img: quay.io/airshipit/armada:af8a9ffd0873c2fbc915794e235dbd357f2adab1
source_helm_bind_dir: /opt/cgcs/helm_charts
target_helm_bind_dir: /www/pages/helm_charts
```

## 运行ansible-playbook
```
ansible-playbook /usr/share/ansible/stx-ansible/playbooks/bootstrap/bootstrap.yml
```