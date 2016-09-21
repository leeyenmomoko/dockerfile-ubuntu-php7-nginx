#!/bin/bash

# environment variable should export to php world
for _curVar in `env | awk -F = '{print $1}'`; do
    if [ -z "${!_curVar}" ]; then
        echo "Environment variable '${_curVar}' not set."
        continue
    fi

    echo "env[${_curVar}] = '${!_curVar}'" | tee -a /etc/php5/fpm/pool.d/www.conf
done
 
echo "DONE"
 
service php5-fpm start 
sleep 2
nginx
tail -f /var/log/nginx/*.log
