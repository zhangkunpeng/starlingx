#!/bin/bash

central=${CENTRAL_IP:-127.0.0.1}
sed -i "s/127.0.0.1/$central/g" /usr/local/apache2/htdocs/index.html

exec "$@"