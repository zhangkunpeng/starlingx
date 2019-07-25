
### HOST UNLOCK

用于解锁starlingx节点

#### 运行环境
已经安装配置好的starlingx环境
- 执行过 sudo config_controller 或 config_subcloud
- 执行过 system host-update 的节点

#### 解锁 simplex 和 duplex
实现 controller-0 、controller-1 的解锁
```
wget https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/host-unlock/stx-2018.10/unlock-allinone.sh
sh unlock-allinone.sh
```
脚本需要一些必要的配置项，通过交互式输入

```
Please input the node name to unlock, default [controller-0]:controller-0
Please input the data interface:ens2f0
Please input a provider network name, default [providernet-a]:providernet-a
Please input the provider network(providernet-a)  type [ flat/vlan ]:vlan
Please input vlan range, min [100]:100
Please input vlan range, max [400]:400
please input the disk name to config cinder, such as [sdb]:sdb
please input the cinder volume size (GB):1000
please input the disk name to config nova volume, such as [sdc]:sdc
please input the cinder volume size (GB):100

>>> Data interface: ens2f0
>>> Provider network name: providernet-a 
>>> Provider network type: vlan 
>>> Provider Netwrok Vlan range: 100-400 
>>> Cinder disk: sdb 
>>> Cinder size: 1000 
>>> Nova disk: sdc 
>>> Nova size: 100 

Apply the above configuration? [y/n]:
```

#### 解锁 Controller Storage
实现 controller-0 、controller-1 以及 compute-* 的解锁
```
wget https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/host-unlock/stx-2018.10/unlock-standard.sh
sh unlock-standrad.sh
```

#### 解锁 中心云 Central Cloud
实现 中心云 controller-0 controller-1的解锁
```
wget https://raw.githubusercontent.com/zhangkunpeng/starlingx/master/host-unlock/stx-2018.10/unlock-central.sh
sh unlock-central.sh
```

