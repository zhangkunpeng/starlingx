#!/bin/bash

registry=registry.local:9001/

echo "登录StarlingX集群镜像仓库，输入集群用户名和密码(参考localhost.yml)"
docker login $registry

sudo docker images |grep -v "registry.local" |grep -v "REPOSITORY" > /tmp/docker_images.lst

image_names=($(cat /tmp/docker_images.lst | awk '{print $1}'));
image_tags=($(cat /tmp/docker_images.lst | awk '{print $2}'));

for(( i=0;i<${#image_names[@]};i++)) do
    #${#array[@]}获取数组长度用于循环
    # image=${image/k8s.gcr.io\//}
    # image=${image/gcr.io\//}
    # image=${image/quay.io\//}
    # image=${image/docker.io\//}
    image=${image_names[i]}:${image_tags[i]}
    localimage=$registry${image}
    if [[ ${image_names[i]} != *.io* ]];then
        localimage=${registry}docker.io/${image}
    fi
    echo "$image ----> $localimage"
    sudo docker tag ${image} $localimage
    sudo docker push $localimage
done

# for(( i=0;i<${#image_names[@]};i++)) do
#     #${#array[@]}获取数组长度用于循环
#     image=${image_names[i]}:${image_tags[i]}
#     image=${image/k8s.gcr.io\//}
#     image=${image/gcr.io\//}
#     image=${image/quay.io\//}
#     image=${image/docker.io\//}
#     sudo docker rmi $registry${image}
# done