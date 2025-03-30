#!/bin/sh

. /config/duckdns.ini

echo ${TOKEN}
echo $(DOMAIN)

echo url="https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=" | curl -k -o /var/log/duck.log -K -