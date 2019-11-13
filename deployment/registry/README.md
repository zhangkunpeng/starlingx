## StarlingX 部署 - 镜像仓库
以下介绍2种部署StarlingX 配置镜像仓库的方法
1. 使用公网镜像仓库（个人搭建，不保证稳定性，有问题可随时联系我，进行维护）
2. 自建私有镜像仓库

### 公网镜像仓库

**镜像仓库地址： `registry.starlingx.cloud:15000`** 这是我个人搭建的仓库，不需要科学上网即可访问，电信用户估计访问速度较快，其他未测。只需要在安装StarlingX时简单配置即可使用。

> 部署STX时,在localhost.yml进行配置

```
$ cat localhost.yml
...
# 下面配置理论上兼容2.0和master，2.0已经验证可用，master还未验证
docker_registries:
  unified:
    url: registry.starlingx.cloud:15000
  defaults:
    url: registry.starlingx.cloud:15000
    secure: False
is_secure_registry: False
...
```

### 自建私有镜像仓库
- 在内网主机上搭建私有仓库，参考：https://github.com/zhangkunpeng/stx-registry

    1. 安装git,pip
    2. `git clone https://github.com/zhangkunpeng/stx-registry.git`
    3. `cd stx-registry && pip install -r requirements.txt && ansible-galaxy install geerlingguy.docker`
    4. (在本机搭建镜像仓库) `ansible-playbook main.yml --limit localhost`
    5. (在远程主机上搭建仓库) 修改hosts文件，配置远端主机的地址和用户密码，执行 `ansible-playbook main.yml --limit remote`
    6. (扩展) 更新StarlingX的主分支镜像，`ansible-playbook main.yml --limit localhost -e "clean_image_cache=True"`

- 在localhost.yml进行配置

```
$ cat localhost.yml
...
# 下面配置理论上兼容2.0和master
docker_registries:
  unified:
    url: <内网仓库地址>:5000
  defaults:
    url: <内网仓库地址>:5000
    secure: False
is_secure_registry: False
...
```

** 以上内容，如果存在问题，请与我联系更新，谢谢。Email: `zhang.kunpeng@99cloud.net` **