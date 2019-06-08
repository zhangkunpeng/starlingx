#!/bin/bash


sudo yum update
sudo yum install docker


CENTRAL_SRS_NAME=registry.cn-shanghai.aliyuncs.com/zhangkunpeng/cental_srs
CENTRAL_SRS_TAG=latest

sudo docker pull $CENTRAL_SRS_NAME:$CENTRAL_SRS_TAG 
sudo docker run -d -p 1935:1935 --name srs $CENTRAL_SRS_NAME:$CENTRAL_SRS_TAG 

