#!/bin/bash


sudo yum update
sudo yum install docker

CENTRAL_IP=$1
EDGE_SRS_NAME=registry.cn-shanghai.aliyuncs.com/zhangkunpeng/cental_srs
EDGE_SRS_TAG=latest
WEBPLAYER_NAME=registry.cn-shanghai.aliyuncs.com/zhangkunpeng/webplayer
WEBPLAYER_TAG=1.0
NTOPNG_NAME=registry.cn-shanghai.aliyuncs.com/zhangkunpeng/ntopng
NTOPNG_TAG=latest

sudo docker pull $EDGE_SRS_NAME:$EDGE_SRS_TAG 
sudo docker run -d -p 1935:1935 --name srs --env CENTRAL_IP=$CENTRAL_IP $EDGE_SRS_NAME:$EDGE_SRS_TAG

sudo docker pull $WEBPLAYER_NAME:$WEBPLAYER_TAG
sudo docker run -d -p 80:80 --name webplayer $WEBPLAYER_NAME:$WEBPLAYER_TAG

sudo docker pull $NTOPNG_NAME:$NTOPNG_TAG
sudo docker run -dt --net=host --name ntopng $NTOPNG_NAME:$NTOPNG_TAG
