

## 准备工作

#### 1. 确认硬件支持虚拟化技术以及PCI passthrouth
由于需要硬件⽀支持，先要确认CPU及主板(motherboard)是否⽀支持Intel或AMD的硬件辅助虚拟化 功能，可以查看官⽅方的硬件⽀支持列列表，或者在BIOS中查看相关选项，还需要⽀支持PCI passthrough的 PCI硬件设备。

#### 2. 在BIOS中打开硬件辅助虚拟化功能⽀支持
- 对于intel cpu, 在主板中开启VT-x及VT-d选项
    - VT-x为开启虚拟化需要
    - VT-d为开启PCI passthrough

    这两个选项⼀一般在BIOS中Advance下CPU和System或相关条⽬目中设置，例例如:

    - VT: Intel Virtualization Technology
    - VT-d: Intel VT for Directed I/O

- 对于 amd cpu, 在主板中开启SVM及IOMMU选项
    - SVM为开启虚拟化需要
    - IOMMU为开启PCI passthrough

#### 3. 确认内核支持iommu
```
cat /proc/cmdline |grep iommu
```
如果没有输出, 则需要修改kernel启动参数 
- 对于intel cpu
1. 编辑 /etc/default/grub ⽂文件, 在 GRUB_CMDLINE_LINUX ⾏行行后⾯面添加: 
```
    intel_iommu=on
```
例如:
```
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/rootrd.lvm.lv=centos/swap rhgb quiet intel_iommu=on"
```
2. 更新grub
```
grub2-mkconfig -o /boot/grub2/grub.cfg
```
- 对于amd cpu

与intel cpu的区别为, 添加的不不是 intel_iommu=on , ⽽而是 iommu=on , 其他步骤⼀一样

#### 4. 确认pci设备驱动信息
确认pci设备驱动信息并从host默认驱动程序中解绑, 以备虚拟机透传使⽤用, 查看pci设备信息, 此处为USB
```
controller-0:~$ lsusb -v 2>/dev/null | grep '^Bus\|iSerial'
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
  iSerial                 1 0000:00:14.0
Bus 001 Device 002: ID 8087:0a2b Intel Corp.
  iSerial                 0
Bus 001 Device 003: ID 046d:081b Logitech, Inc. Webcam C310
  iSerial                 2 044451A0
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
  iSerial                 1 0000:00:14.0
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
  iSerial                 1 0000:02:00.0
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
  iSerial                 1 0000:02:00.0

controller-0:~$ lspci -nn |grep USB
00:14.0 USB controller [0c03]: Intel Corporation Sunrise Point-H USB 3.0 xHCI Controller [8086:a12f] (rev 31)
02:00.0 USB controller [0c03]: ASMedia Technology Inc. Device [1b21:2142]
```
其中[8086:a12f]的8086为pci设备的vendor id, a12f为product id

