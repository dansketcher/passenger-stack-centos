# Require our stack
%w(repos essential apache git ruby_enterprise memcached postgresql mysql sqlite subversion ntp imagemagick utilities).each do |r|
  require File.join(File.dirname(__FILE__), 'stack', r)
end

# http://www.klaverstyn.com.au/wiki/index.php?title=Internode_repository


policy :everyone, :roles => [:app, :web, :db] do
  requires :yum_repositories_external
  requires :ntp                     # Network Time Protocol daemon
  requires :git                     # Git or Subversion
  requires :subversion              # Git or Subversion
  requires :archivers
  requires :gnupg
  requires :gnupg2
  requires :duplicity
end

policy :data, :roles => :db do
  requires :postgres
  requires :ruby_enterprise         # Ruby Enterprise edition
  requires :postgresql_driver       # PostgreSQL gem
  requires :rmagick                 # rmagick gem
end

policy :web, :roles => :app do
  requires :apache                  # Apache
  requires :apache_etag_support     # == Apache extras
  requires :apache_deflate_support  # Read about these specialties in 
  requires :apache_expires_support  # stack/apache.rb
  requires :apache_ssl_support      # ==

  requires :postgres_client         # PostgreSQL client
  requires :ruby_enterprise         # Ruby Enterprise edition
  requires :appserver               # Passenger
  requires :postgresql_driver       # PostgreSQL gem
  
  requires :memcached               # Memcached
  requires :libmemcached            # Libmemcached
  requires :imagemagick             # Imagemagick
  requires :rmagick                 # rmagick gem
  requires :phppgadmin
  requires :apache_mod_dav_svn      # Subversion mod_svn Apache module
end


deployment do
  # mechanism for deployment
  delivery :capistrano do
    begin
      recipes 'Capfile'
    rescue LoadError
      recipes 'deploy'
    end
  end
 
  # source based package installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/src'
    builds   '/usr/local/build'
  end
end

# Depend on a specific version of sprinkle 
begin
  gem 'sprinkle', ">= 0.2.1" 
rescue Gem::LoadError
  puts "sprinkle 0.2.1 required.\n Run: `sudo gem install sprinkle`"
  exit
end
