#!/usr/bin/env bash
mkdir -p var/fails

yarn install
bower install --allow-root

redis-server --daemonize yes
service mysql start
mysql -u root -e "CREATE DATABASE $SYMFONY__DATABASE_NAME"
mysql -u root -e "CREATE DATABASE $SYMFONY__DATABASE_NAME_TEST"
[ ! -f \"vendor/composer.phar\" ] && php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && php composer-setup.php && mkdir -p vendor && mv composer.phar vendor/composer.phar && rm composer-setup.php
gulp styles
php vendor/composer.phar install --prefer-dist
php -d memory_limit=2048M bin/console --env=test cache:warmup --no-debug
bin/console --env=test bazinga:js-translation:dump
bin/console --env=test fos:js-routing:dump --target="web/js/fos_js_routes_test.js"
bin/console --env=test assetic:dump --no-debug
bin/behat --dry-run | grep "Scenario: " | awk '{print $(NF)}' > var/scenarios
