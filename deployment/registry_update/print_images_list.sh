sudo docker images |grep -v "registry.local" |grep -v "REPOSITORY" > /tmp/docker_images.lst

image_names=($(cat /tmp/docker_images.lst | awk '{print $1}'));
image_tags=($(cat /tmp/docker_images.lst | awk '{print $2}'));

for(( i=0;i<${#image_names[@]};i++)) do
    #${#array[@]}获取数组长度用于循环
    echo ${image_names[i]}:${image_tags[i]}
done
