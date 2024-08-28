#!/bin/bash

# turn on bash's job control
set -m

# add user "adu" and change ownership of mounted dir.
# useradd adu
chown adu:adu -R /var/adu
chomod 740 -R /var/adu

# Copy properties if not exist.
cp -n /usr/local/adu/adu.properties /var/adu/data/
cp -n /usr/local/adu/image.properties /var/adu/data/

# Start the primary server process
/usr/local/tomcat/bin/catalina.sh run &
status=$?
if [ $status -ne 0 ]; then
  echo "$(date) # Failed to start catalina.sh: $status" >> /var/adu/data/init_status.log
  exit $status
else
  echo "$(date) # Starting tomcat server ... status: $status" >> /var/adu/data/init_status.log
fi

# Wait for server to start.
sleep 5

# Start the secondry ADU-init.py process
/usr/local/adu/watcherInit.py

# Bring the primary process back into the foreground.
fg %1
