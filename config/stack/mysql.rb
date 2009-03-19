package :mysql, :provides => :database do
  description 'MySQL Database'
  yum 'mysql-server'
  
  verify do
    has_executable 'mysql'
  end
end
 
package :mysql_driver, :provides => :ruby_database_driver do
  description 'Ruby MySQL database driver'

  verify do
    has_gem 'mysql'
  end
  
  requires :mysql, :mysql_dependencies, :ruby_enterprise
end

package :mysql_dependencies do
  yum 'mysql-devel' do
    post :install, 'gem install mysql -- --with-mysql-config=/usr/bin/mysql_config'
  end
end
