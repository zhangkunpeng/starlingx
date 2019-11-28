## 喜大普奔，安装StarlingX再也不需要翻墙和搭建私有仓库了

localhost.yaml 里修改以下配置，亲测可用
```
docker_registries:
  k8s.gcr.io:
   url: gcr.azk8s.cn/google-containers
  gcr.io:
    url: gcr.azk8s.cn
  quay.io:
    url: quay.azk8s.cn
```