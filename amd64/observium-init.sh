#!/usr/bin/env bash

function WriteLog() {
  echo "$(date +%Y-%m-%d\ %H:%M:%S) [$(basename ${0})] ${1}"
  return 0
}

# dynamically enforce timezone in container
if [ -n "${TZ}" ]; then
   WriteLog "Set timezone to '${TZ}'"
   if [ -f "/usr/share/zoneinfo/${TZ}" ]; then
      echo "${TZ}" > /etc/timezone
      ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
   else
      WriteLog "Invalid specific $TZ timezone and use the default of `cat /etc/timezone` instead."
   fi
fi

count=0
while true
do
   let count++
   WriteLog "Check connection to observium database (attempt #${count})"
   MYSQL_PWD="${OBSERVIUM_DB_PASS}" mysql \
      --host="${OBSERVIUM_DB_HOST}" \
      --user="${OBSERVIUM_DB_USER}" \
      --execute="select 1" \
      "${OBSERVIUM_DB_NAME}" >/dev/null && break
   sleep 5
done
WriteLog "Connection to observium database checked after ${count} attempts"

# ensure rrd data is always accessible
WriteLog "Set /opt/observium/rrd directory to www-data:www-data"
chown -R www-data:www-data "/opt/observium/rrd"

# On first run create the default schema
# Otherwise ensure the schema is up to date with the code
WriteLog "Init/Update database schema"
/opt/observium/discovery.php -u

# ensure the admin user is always defined
WriteLog "Add admin user"
/opt/observium/adduser.php "${OBSERVIUM_ADMIN_USER}" "${OBSERVIUM_ADMIN_PASS}" 10

# create a reusable environment for cronjobs
WriteLog "Build environment script for cronjobs"
(
   echo "export OBSERVIUM_ADMIN_USER=${OBSERVIUM_ADMIN_USER}"
   echo "export OBSERVIUM_ADMIN_PASS=${OBSERVIUM_ADMIN_PASS}"
   echo "export OBSERVIUM_DB_HOST=${OBSERVIUM_DB_HOST}"
   echo "export OBSERVIUM_DB_USER=${OBSERVIUM_DB_USER}"
   echo "export OBSERVIUM_DB_PASS=${OBSERVIUM_DB_PASS}"
   echo "export OBSERVIUM_DB_NAME=${OBSERVIUM_DB_NAME}"
   echo "export OBSERVIUM_BASE_URL=${OBSERVIUM_BASE_URL}"
) > "/opt/observium/observium-setenv.sh"
chmod 750 "/opt/observium/observium-setenv.sh"

exit 0
