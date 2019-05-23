### 问题描述
Openstack/StarlingX在server没有配置正常的网络的情况下，进入到server的CLI的方法。

### 解决方法
1. 切换到边缘云后输入`ip net`命令：
```
# ip net
```
回显如下：
```
qrouter-18467dbd-692b-432d-acdf-56d18b334688
qdhcp-4f7426db-5c8a-4175-8866-18925020a39c
```
2. 进入到dhcp的bash中：
```
# sudo ip net exec \
qdhcp-4f7426db-5c8a-4175-8866-18925020a39c bash 
```
3. 查看ip信息：
```
# ip a 
```
回显如下：
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 169.254.169.254/32 brd 169.254.169.254 scope global lo
       valid_lft forever preferred_lft forever
13: tap56f20699-11: <BROADCAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 1000
    link/ether fa:16:3e:82:1d:a1 brd ff:ff:ff:ff:ff:ff
    inet 172.16.130.145/24 brd 172.16.130.255 scope global tap56f20699-11
       valid_lft forever preferred_lft forever
    inet 192.168.1.2/24 brd 192.168.1.255 scope global tap56f20699-11
       valid_lft forever preferred_lft forever
    inet6 fe80::f816:3eff:fe82:1da1/64 scope link
       valid_lft forever preferred_lft forever
```
其中`192.168.1.2`就是我们server的网关地址。

4. 我们server的ip地址在配置网络的时候，是`192.168.1.10`。所以我们直接`ssh`上去即可。
```
ssh ubuntu@192.168.1.10
```
