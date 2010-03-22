package :postgres, :provides => :database do
  description 'PostgreSQL database'
  
  pg_hba_conf = "/var/lib/pgsql/data/pg_hba.conf"
  
  yum 'postgresql-server' do
    # Use initdb so that the SELinux access controls are set correctly
    post :install, 'sudo /sbin/service postgresql initdb'
    post :install, %q(sed -i "s/127.0.0.1\/32          ident/127.0.0.1\/32          md5/" /var/lib/pgsql/data/pg_hba.conf)
    post :install, %q(sed -i "s/::1\/128               ident/::1\/128               md5/" /var/lib/pgsql/data/pg_hba.conf)
    post :install, 'sudo /sbin/service postgresql start'
    post :install, 'sudo /sbin/chkconfig postgresql on'
  end

  verify do
    has_executable '/etc/init.d/postgresql'
    file_contains pg_hba_conf, "127.0.0.1/32          md5"
  end
  
  requires :yum_repository_pgdg, :postgres_client
end

package :postgres_archiving do
  postgresql_conf = "/var/lib/pgsql/data/postgresql.conf"
  backup_sh = "/var/lib/pgsql/data/backup.sh"
  
  config = %Q(
# WAL-Archiving
archive_mode = on
archive_command = '/usr/bin/test ! -f /var/lib/pgsql/backups/%f && /usr/bin/rsync -arv %p /var/lib/pgsql/backups/%f </dev/null'
archive_timeout = 300
)

  # c.f: http://stackoverflow.com/questions/2094963/postgres-improving-pg-dump-pg-restore-performance
  # http://www.postgresql.org/docs/8.4/static/continuous-archiving.html#BACKUP-ARCHIVING-WAL
  # Useful for backups and:
  #   o http://archives.postgresql.org/sydpug/2006-10/msg00001.php
  #   o http://scale-out-blog.blogspot.com/2009/02/simple-ha-with-postgresql-point-in-time.html
  backup_script = %Q(#!/bin/env bash
# Change the postgres user password with : ALTER ROLE postgres WITH PASSWORD 'something_secret';
export PGPASSWORD=<change me>
DATE="`date "+%F-%T"`"
/usr/bin/psql template1 -h localhost -U postgres -c "select pg_start_backup('${DATE}')" &&
mkdir /var/lib/pgsql/backup-pre-${DATE} && chown postgres:postgres /var/lib/pgsql/backup-pre-${DATE} &&
mv /var/lib/pgsql/backups/*  /var/lib/pgsql/backup-pre-${DATE}/ &&
/usr/bin/rsync -a --delete /var/lib/pgsql/data/ /var/lib/pgsql/backups/ &&
/usr/bin/psql template1 -h localhost -U postgres -c "select pg_stop_backup()"
)
  
  push_text config, postgresql_conf, :sudo => true
  push_text backup_script, backup_sh, :sudo => true
  
  yum "rsync" do
    post :install, "chown postgres:postgres #{backup_sh}"
    post :install, "chmod 700 #{backup_sh}" # user execute
    post :install, "chcon -R -h -t postgresql_exec_t /usr/bin/test"
    post :install, "chcon -R -h -t postgresql_exec_t /usr/bin/rsync"
    post :install, 'sudo /sbin/service postgresql restart'
  end
 
  verify do
    has_rpm "rsync"
    has_file postgresql_conf
    has_file backup_sh
    file_contains postgresql_conf, "WAL-Archiving"
  end
  
  requires :postgres
end

package :postgresql_driver, :provides => :ruby_database_driver do
  description 'Ruby PostgreSQL database driver'
  gem 'pg'
  
  verify do
    has_gem 'pg'
  end
  
  requires :postgres_client, :postgres_dependencies, :ruby_enterprise
end

package :postgres_dependencies do
  yum 'postgresql-devel.x86_64'
end

package :postgres_client do
  yum 'postgresql-libs postgresql postgresql-contrib'
  verify do
    has_executable 'psql'
  end
end

package :phppgadmin do
  yum 'phpPgAdmin' do
    post :install, "/usr/sbin/setsebool -P httpd_can_network_connect_db 1"
  end
  
  requires :yum_repository_pgdg, :postgres_client, :webserver
end
