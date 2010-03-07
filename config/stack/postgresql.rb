package :postgres, :provides => :database do
  description 'PostgreSQL database'
  yum 'postgresql-server' do
    # Use initdb so that the SELinux access controls are set correctly
    post :install, 'sudo /sbin/service postgresql initdb'
    post :install, 'sudo /sbin/service postgresql start'
  end
  
  verify do
    has_executable '/etc/init.d/postgresql'
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
