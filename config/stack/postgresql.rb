package :postgres, :provides => :database do
  description 'PostgreSQL database'
  
  pg_hba_conf = "/var/lib/pgsql/data/pg_hba.conf"
  
  yum 'postgresql-server' do
    # Use initdb so that the SELinux access controls are set correctly
    post :install, 'sudo /sbin/service postgresql initdb'
    post :install, 'sudo /sbin/service postgresql start'
    post :install, 'sudo /sbin/chkconfig postgresql on'
    post :install, %q(sed -i "s/127.0.0.1\/32          ident/127.0.0.1\/32          md5/" /var/lib/pgsql/data/pg_hba.conf)
    post :install, %q(sed -i "s/::1\/128               ident/::1\/128               md5/" /var/lib/pgsql/data/pg_hba.conf)
  end

  verify do
    has_executable '/etc/init.d/postgresql'
    file_contains pg_hba_conf, "127.0.0.1/32          md5"
  end
  
  requires :yum_repository_pgdg, :postgres_client
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
  yum 'phpPgAdmin'
  
  requires :yum_repository_pgdg, :postgres_client, :webserver
end
