#!/usr/bin/env bash

cp /tmp/resolv.conf /etc/

cd /app

if [ "$INITDB" == "1" ]; then
  rails db:setup
  mysql -h db -u$MYSQL_USER -p$MYSQL_PASWORD < /shell/vyyo.sql
  mysql -h db -u$MYSQL_USER -p$MYSQL_PASWORD < /shell/arristool_development.sql
fi

rm -f /app/tmp/pids/server.pid
bundle exec rails s -b 0.0.0.0 -p 3000

sleep 100000000
