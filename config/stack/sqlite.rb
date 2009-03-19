package :sqlite, :provides => :database do
  description 'SQLite database'
  yum 'sqlite'
  
  verify do
    has_executable 'sqlite3'
  end
end
 
package :sqlite_driver, :provides => :ruby_database_driver do
  description 'Ruby SQLite database driver'
  gem 'sqlite3-ruby'
  
  verify do
    has_gem 'sqlite3-ruby'
  end
  
  requires :sqlite, :sqlite_dependencies, :ruby_enterprise
end

package :sqlite_dependencies do
  yum 'sqlite-devel'
end
