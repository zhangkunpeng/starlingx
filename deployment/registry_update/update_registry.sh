#!/bin/bash

registry=47.100.127.100:5000/
sudo docker images |grep -v "registry.local" |grep -v "REPOSITORY" > /tmp/docker_images.lst

image_names=($(cat /tmp/docker_images.lst | awk '{print $1}'));
image_tags=($(cat /tmp/docker_images.lst | awk '{print $2}'));

for(( i=0;i<${#image_names[@]};i++)) do
    #${#array[@]}获取数组长度用于循环
    echo ${image_names[i]}:${image_tags[i]}
    image=${image_names[i]}:${image_tags[i]}
    image=${image/k8s.gcr.io\//}
    image=${image/gcr.io\//}
    image=${image/quay.io\//}
    image=${image/docker.io\//}
    image_old=${image_names[i]}:${image_tags[i]}
    sudo docker tag ${image_old} $registry${image}
    sudo docker push $registry${image}
done

for(( i=0;i<${#image_names[@]};i++)) do
    #${#array[@]}获取数组长度用于循环
    image=${image_names[i]}:${image_tags[i]}
    image=${image/k8s.gcr.io\//}
    image=${image/gcr.io\//}
    image=${image/quay.io\//}
    image=${image/docker.io\//}
    sudo docker rmi $registry${image}
done