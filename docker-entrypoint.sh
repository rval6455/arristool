#!/usr/bin/env bash

cp /tmp/resolv.conf /etc/

cd /app

if [ "$INITDB" -eq "1" ]; then
  echo "Initializing Rails Database"
  rails db:setup
  echo "Importing vyyo database"
  mysql -h db -u$MYSQL_USER -p$MYSQL_PASSWORD < /share/vyyo.sql
  echo "Importing arris database"
  mysql -h db -u$MYSQL_USER -p$MYSQL_PASSWORD < /share/arristool_development.sql
fi

rm -f /app/tmp/pids/server.pid
bundle exec rails s -b 0.0.0.0 -p 3000

sleep 100000000
