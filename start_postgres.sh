#!/bin/bash

DB_NAME=${POSTGRES_DB:-}
DB_USER=${POSTGRES_USER:-}
DB_PASS=${POSTGRES_PASSWORD:-}
PG_CONFDIR="/var/lib/pgsql/data"

__create_user() {
  #Grant rights

  #echo create user params:
  #echo $DB_NAME
  #echo $DB_USER
  #echo $DB_PASS

  usermod -G wheel postgres

  # Check to see if we have pre-defined credentials to use
if [ -n "${DB_USER}" ]; then
  if [ -z "${DB_PASS}" ]; then
    echo ""
    echo "WARNING: "
    echo "No password specified for \"${DB_USER}\". Generating one"
    echo ""
    DB_PASS=$(pwgen -c -n -1 12)
    echo "Password for \"${DB_USER}\" created as: \"${DB_PASS}\""
  fi
    echo "Creating user \"${DB_USER}\"..."
    echo "CREATE ROLE ${DB_USER} with CREATEROLE login superuser PASSWORD '${DB_PASS}';" |
      sudo -u postgres -H postgres --single \
       -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
  
fi

if [ -n "${DB_NAME}" ]; then
  echo "Creating database \"${DB_NAME}\"..."
  echo "CREATE DATABASE ${DB_NAME};" | \
    sudo -u postgres -H postgres --single \
     -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}

  if [ -n "${DB_USER}" ]; then
    echo "Granting access to database \"${DB_NAME}\" for user \"${DB_USER}\"..."
    echo "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};" |
      sudo -u postgres -H postgres --single \
      -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
  fi
fi
}


#__run_supervisor() {
#supervisord -n
#}

__run (){
 #echo configure pg_hba.conf:
 # not needet - done in dockerfile
 #sed -i -e 's/ident/trust/g' /var/lib/pgsql/data/pg_hba.conf
 #sed -i -e 's/md5/trust/g' /var/lib/pgsql/data/pg_hba.conf
 #sed -i -e 's/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf

echo configure postgresql.conf:
sed -itmp -e 's/#listen_addresses = \x27localhost\x27/listen_addresses = \x27*\x27/g' /var/lib/pgsql/data/postgresql.conf

echo create zabbix db:
#start server
sudo -HEu postgres /usr/pgsql-9.6/bin/pg_ctl -D /var/lib/pgsql/data -w start >/dev/null
/bin/psql -U postgres -c "CREATE DATABASE zabbix_db WITH ENCODING='UTF-8';"
/bin/psql -U postgres -c "CREATE USER zabbix WITH PASSWORD 'zabbix';"
/bin/psql -U postgres -c "GRANT ALL ON DATABASE zabbix_db TO zabbix;"
/bin/psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE zabbix_db to postgres;"
/bin/psql -U postgres -c "ALTER USER Postgres WITH PASSWORD 'postgres';"
/bin/psql -U zabbix zabbix_db < /schema.sql
/bin/psql -U zabbix zabbix_db < /images.sql
/bin/psql -U zabbix zabbix_db < /data.sql

# stop the postgres server
sudo -HEu postgres /usr/pgsql-9.6/bin/pg_ctl -D /var/lib/pgsql/data -w stop >/dev/null
#exec_as_postgres ${PG_BINDIR}/pg_ctl -D ${PG_DATADIR} -w stop >/dev/null

echo run server:
su postgres -c '/usr/pgsql-9.6/bin/postgres -D /var/lib/pgsql/data'


}

# Call all functions

__create_user
__run

#__run_supervisor
