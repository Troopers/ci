#!/usr/bin/env bash
cp app/config/parameters.yml.dist app/config/parameters.yml
mkdir -p var/fails
service mysql start
redis-server --daemonize yes
Xvfb :99 -ac &
export DISPLAY=:99
nohup java -jar /selenium-server-standalone-2.53.0.jar 2> /dev/null > /dev/null &
nohup /elasticsearch-2.3.4/bin/elasticsearch -Des.insecure.allow.root=true 2> /dev/null > /dev/null &
nohup mailcatcher 2> /dev/null > /dev/null &
mysql -u root -e "CREATE DATABASE $SYMFONY__DATABASE_NAME_TEST"
bin/console --env=test doctrine:schema:create
bin/console --env=test server:run 127.0.0.1:80 &
sleep 3

