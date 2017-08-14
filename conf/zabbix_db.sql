CREATE DATABASE zabbix_db WITH ENCODING='UTF-8';
CREATE USER zabbix WITH PASSWORD 'zabbix';
GRANT ALL ON DATABASE zabbix_db TO zabbix;
GRANT ALL PRIVILEGES ON DATABASE zabbix_db to postgres;
ALTER USER Postgres WITH PASSWORD 'editar_password';
