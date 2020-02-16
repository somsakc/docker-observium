#!/bin/bash

count=0
rc=1

while [ $rc -ne 0 ]
do
   let count++
   echo "[$count] Verifying coonection to observium database."
   mysql -h $OBSERVIUM_DB_HOST -u $OBSERVIUM_DB_USER --password=$OBSERVIUM_DB_PASS -e "select 1" $OBSERVIUM_DB_NAME >/dev/null
   rc=$?
   [ $rc -ne 0 ] && sleep 5
done

echo "Connected to observium database successfully."

tables=`mysql -h $OBSERVIUM_DB_HOST -u $OBSERVIUM_DB_USER --password=$OBSERVIUM_DB_PASS -e "show tables" $OBSERVIUM_DB_NAME 2>/dev/null`

if [ -z "$tables" ]
then
   echo "Setting /opt/observium/rrd directory to www-data:www-data."
   chown -v www-data:www-data /opt/observium/rrd
   echo "Initializing database schema in first time running for observium."
   /opt/observium/discovery.php -u
   /opt/observium/adduser.php $OBSERVIUM_ADMIN_USER $OBSERVIUM_ADMIN_PASS 10
else
  echo "Database schema initialization has been done already."
  sleep 5
fi

echo "export OBSERVIUM_ADMIN_USER=$OBSERVIUM_ADMIN_USER" >> /opt/observium/observium-setenv.sh
echo "export OBSERVIUM_ADMIN_PASS=$OBSERVIUM_ADMIN_PASS" >> /opt/observium/observium-setenv.sh
echo "export OBSERVIUM_DB_HOST=$OBSERVIUM_DB_HOST" >> /opt/observium/observium-setenv.sh
echo "export OBSERVIUM_DB_USER=$OBSERVIUM_DB_USER" >> /opt/observium/observium-setenv.sh
echo "export OBSERVIUM_DB_PASS=$OBSERVIUM_DB_PASS" >> /opt/observium/observium-setenv.sh
echo "export OBSERVIUM_DB_NAME=$OBSERVIUM_DB_NAME" >> /opt/observium/observium-setenv.sh

exit 0
