#!/bin/bash

central=($CENTRAL_IP:127.0.0.1)
sed -i "s/127.0.0.1/$central/g" /srs/conf/edge.conf

exec "$@"