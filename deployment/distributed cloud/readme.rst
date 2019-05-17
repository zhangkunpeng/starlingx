Distributed Cloud
==================

Deployment description
-----------------------

分布式云是有一个中心多个边缘组成。中心云主要用于对边缘云的监控、资源管理功能，通过配置，中心云也可以提供计算能力。
边缘云主要是提供计算资源，其本身也拥有对自身的资源管理的能力。
中心云和边缘云是通过三层网络通讯，主要用于镜像推送以及数据同步。

.. image:: DistributedCloud.jpg
   :scale: 50 %

中心云推荐采用双节点HA部署方式
边缘云的部署方式较多，主要包括 simplex（单节点allinone），duplex（双节点 allinone），Controller storage(多节点本地存储)，Dedicated storage(多节点ceph存储)

-----------------
准备环境
-----------------

**********
中心云
**********

- Standard Controller: https://docs.starlingx.io/deployment_guides/current/controller_storage.html#preparing-controller-storage-servers>

**********
边缘云
**********

- Simplex: https://docs.starlingx.io/deployment_guides/current/simplex.html#preparing-an-all-in-one-simplex-server
- Duplex: https://docs.starlingx.io/deployment_guides/current/duplex.html#preparing-all-in-one-duplex-servers
- Controller Storage: https://docs.starlingx.io/deployment_guides/current/controller_storage.html#preparing-controller-storage-servers>
- Dedicated Storage: https://docs.starlingx.io/deployment_guides/latest/dedicated_storage/index.html#preparing-dedicated-storage-servers

