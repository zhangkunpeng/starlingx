# live-stream
基于分布式云的网络直播应用

### 准备环境
- 中心云和边缘云上各上创建一台centos实例，两台虚拟机通过业务网络连通
- 配置本机免密登录, ssh-copy-id -i {id_rsa.pub} username@XXX

### 部署直播应用
- 修改ansible/hosts文件中的主机地址
- 切换到ansible/目录下
- 执行命令 ansible-playbook all.yml