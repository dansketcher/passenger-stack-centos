package :apache, :provides => :webserver do
  description 'Apache2 web server.'
  yum 'httpd' do
    post :install, 'sudo /sbin/service httpd start'
  end

  verify do
    has_executable '/usr/sbin/httpd'
  end

  requires :build_essential
end

package :passenger, :provides => :appserver do
  description 'Phusion Passenger (mod_rails)'
  version '2.1.3'
  gem 'passenger' do
   post :install, 'echo -en "\n\n\n\n" | sudo passenger-install-apache2-module'

    # Create the passenger conf file
    post :install, 'mkdir -p /etc/httpd/extras'
    post :install, 'touch /etc/httpd/extras/passenger.conf'
    post :install, 'echo "Include /etc/httpd/extras/passenger.conf"|sudo tee -a /etc/httpd/conf/httpd.conf'

    [%Q(LoadModule passenger_module /usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}/ext/apache2/mod_passenger.so),
    %Q(PassengerRoot /usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{version}),
    %q(PassengerRuby /usr/local/bin/ruby),
    %q(RailsEnv production)].each do |line|
      post :install, "echo '#{line}' |sudo tee -a /etc/httpd/extras/passenger.conf"
    end

    # Restart apache to note changes
    post :install, '/sbin/service httpd restart'
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
