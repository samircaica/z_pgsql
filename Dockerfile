# Docker Postgres Tutorial
# https://www.andreagrandi.it/2015/02/21/how-to-create-a-docker-image-for-postgresql-and-persist-data/

FROM centos:latest

RUN rpm -Uvh https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm

RUN yum update -y ; yum -y install sudo postgresql96-server postgresql96-devel postgresql96-contrib --nogpgcheck; yum clean all


ENV PATH /usr/pgsql-9.6/bin:/:$PATH
ENV PGDATA /var/lib/pgsql/data

ADD ./postgresql-setup /usr/bin/postgresql-setup
#ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start_postgres.sh /start_postgres.sh

RUN chmod +x /usr/bin/postgresql-setup
RUN chmod +x /start_postgres.sh


RUN /usr/bin/postgresql-setup initdb

#ADD ./conf/postgresql.conf /var/lib/pgsql/data/postgresql.conf
ADD ./conf/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
ADD ./conf/zabbix_db.sql /

ADD ./conf/schema.sql /schema.sql
ADD ./conf/images.sql /images.sql
ADD ./conf/data.sql /data.sql

#RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf 
RUN chown -v postgres.postgres /var/lib/pgsql/data/pg_hba.conf


#RUN echo "host    all             all             all               trust" >> /var/lib/pgsql/data/pg_hba.conf

VOLUME ["/var/lib/pgsql/data"]
#VOLUME ["/var/lib/pgsql"]

EXPOSE 5432

CMD ["/bin/bash", "/start_postgres.sh"]