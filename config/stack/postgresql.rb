package :postgres, :provides => :database do
  description 'PostgreSQL database'
  yum 'postgresql-server' do
   post :install, 'sudo rm -Rf /var/lib/pgsql'
   post :install, 'sudo mkdir /var/lib/pgsql'
   post :install, 'sudo chown postgres:postgres /var/lib/pgsql'
   post :install, 'sudo sudo -u postgres initdb --encoding=UTF8 --pgdata=/var/lib/pgsql/data'
   post :install, 'sudo /sbin/service postgresql start'
  end
  
  verify do
    has_executable 'psql'
  end
end
 
package :postgresql_driver, :provides => :ruby_database_driver do
  description 'Ruby PostgreSQL database driver'
  gem 'ruby-pg'
  
  verify do
    has_gem 'ruby-pg'
  end
  
  requires :postgres, :postgres_dependencies, :ruby_enterprise
end

package :postgres_dependencies do
  yum 'postgresql-devel'
end
