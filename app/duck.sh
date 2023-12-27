#!/bin/sh

. /config/duckdns.ini

echo ${TOKEN}

echo url="https://www.duckdns.org/update?domains=bulky.duckdns.org&token=${TOKEN}f&ip=" | curl -k -o /logging/duckdns/duck.log -K -