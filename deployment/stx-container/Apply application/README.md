## Apply application中的镜像问题

在执行这一步的时候，遇到的问题和之前的问题不太一样，不能简单的换镜像源。

不能换镜像源的原因：
镜像源写在代码里，不知道怎么改。

不能挂代理的原因：
挂代理之后，由于代码逻辑是先看本地镜像源，再看远端镜像源，所以就会导致
本地镜像源因为代理的缘故访问出错。
```
'Get http://192.168.204.2:9001 BAD GATEWAY'
```

所以目前采取的方式是；不用代理，也不换镜像源。
而是事先下载本地镜像源中没有镜像。
其中涉及到的镜像有：
1.  `docker pull gcr.io/google_containers/defaultbackend:1.0`
2.  

----
我们采取的方式是使用代理。但是在使用之前需要注意一些事。
### 配置docker代理



### 重启armada_service 容器
首先找到armada_service容器ID。
`sudo docker container ls -a | grep armada_service`
回显如下：
```
9c5262ba50ac        quay.io/airshipit/armada:af8a9ffd0873c2fbc915794e235dbd357f2adab1   "./entrypoint.sh ser…"   15 minutes ago       Up 11 minutes                    8000/tcp            armada_service
```
然后暂停该容器服务：
`sudo docker container stop  9c5262ba50ac`
最后删除该容器(在执行`system application-apply`的时候它会自动启动这个容器)：
`sudo docker container rm 9c5262ba50ac`


### 在下载镜像没有出现其他问题之后，又出现了这个错误：

```
ERROR armada.cli IsADirectoryError: [Errno 21] Is a directory: '/armada/.kube/config'
```

在容器中执行命令行：
`sudo docker exec -it 9c5262ba50ac bash`


---

附上一些在执行`Apply application` 中常用的命令：
1. `system application-upload helm-charts-manifest.tgz`
2. `system application-remove stx-openstack`
3. `system application-delete stx-openstack`

`docker cp <container>:/path/to/file.ext .`
`docker cp file.ext <container>:/path/to/file.ext`
