package :apache, :provides => :webserver do
  description 'Apache2 web server.'
  yum 'httpd' do
    post :install, 'sudo /sbin/service httpd start'
  end

  verify do
    has_executable '/usr/sbin/httpd'
  end

  requires :yum_repository_pgdg, :build_essential
end

package :passenger, :provides => :appserver do
  description 'Phusion Passenger (mod_rails)'
  version '2.2.10'
  gem 'passenger' do
    post :install, "sudo /usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}/bin/passenger-install-apache2-module --auto"

    # Per passenger docs
    # http://www.modrails.com/documentation/Users%20guide.html#_the_apache_error_log_says_that_the_spawn_manager_script_does_not_exist_or_that_it_does_not_have_permission_to_execute_it
    post :install, "chcon -R -h -t httpd_sys_content_t /usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}"

    # Create the passenger conf file
    post :install, 'mkdir -p /etc/httpd/extras'
    post :install, 'touch /etc/httpd/extras/passenger.conf'
    post :install, 'echo "Include /etc/httpd/extras/passenger.conf"|sudo tee -a /etc/httpd/conf/httpd.conf'

    [%Q(LoadModule passenger_module /usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}/ext/apache2/mod_passenger.so),
    %Q(PassengerRoot /usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}),
    %q(PassengerRuby /usr/local/bin/ruby),
    %q(RailsEnv production),
    %q(PassengerPoolIdleTime 0),
    %q(PassengerUseGlobalQueue on),
    %q(# PassengerMaxRequests 5000),
    %q(PassengerStatThrottleRate 4),
    %q(RailsAppSpawnerIdleTime 0)
    ].each do |line|
      post :install, "echo '#{line}' |sudo tee -a /etc/httpd/extras/passenger.conf"
    end

    # Restart apache to note changes
    post :install, '/sbin/service httpd restart'
    # You may get an error message:
    # [Thu Aug 20 12:46:59 2009] [error] *** Passenger could not be initialized because of this error: Could not connect to the ApplicationPool server: Broken pipe (32)
    # Which can be ignored per:
    # http://stackoverflow.com/questions/259542/apache-cannot-initialize-passenger-broken-pipe-32-when-connecting-to-applicati
    # However this script will fail until you fix it.
  end

  verify do
    has_file "/etc/httpd/extras/passenger.conf"
    has_file "/usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}/ext/apache2/mod_passenger.so"
    has_directory "/usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}"
  end

  requires :apache, :ruby_enterprise, :passenger_dependencies
end

# These "installers" are strictly optional, I believe
# that everyone should be doing this to serve sites more quickly.

# Enable SSL
package :apache_ssl_support do
  yum "openssl mod_ssl"

  verify do
    #has_file '/etc/httpd/modules/mod_ssl.so'
    has_file '/etc/httpd/conf.d/ssl.conf'
  end

  requires :apache
end

# Enable ETags
package :apache_etag_support do
  apache_conf = "/etc/httpd/conf/httpd.conf"
  config = <<eol

# Passenger-stack-etags
FileETag MTime Size
eol

  push_text config, apache_conf, :sudo => true
  verify { file_contains apache_conf, "Passenger-stack-etags"}
  requires :apache
end

# mod_deflate, compress scripts before serving.
package :apache_deflate_support do
  apache_conf = "/etc/httpd/conf/httpd.conf"
  config = <<eol
# Passenger-stack-deflate
<IfModule mod_deflate.c>
  # compress content with type html, text, and css
  AddOutputFilterByType DEFLATE text/css text/html text/javascript application/javascript application/x-javascript text/js text/plain text/xml
  <IfModule mod_headers.c>
    # properly handle requests coming from behind proxies
    Header append Vary User-Agent
  </IfModule>
</IfModule>
eol

  push_text config, apache_conf, :sudo => true
  verify { file_contains apache_conf, "Passenger-stack-deflate"}
  requires :apache
end

# mod_expires, add long expiry headers to css, js and image files
package :apache_expires_support do
  apache_conf = "/etc/httpd/conf/httpd.conf"

  config = <<eol
# Passenger-stack-expires
<IfModule mod_expires.c>
  <FilesMatch "\.(jpg|gif|png|css|js)$">
       ExpiresActive on
       ExpiresDefault "access plus 1 year"
   </FilesMatch>
</IfModule>
eol

  push_text config, apache_conf, :sudo => true
  verify { file_contains apache_conf, "Passenger-stack-expires"}
  requires :apache
end

package :passenger_dependencies do
  yum %w(httpd-devel apr-devel)
end
