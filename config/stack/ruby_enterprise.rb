package :ruby_enterprise do
  description 'Ruby Enterprise Edition'
  version '1.8.7-2010.01'

  build_path = "/usr/local/build/ruby-enterprise-#{version}"
  #pre :install, "rm -rf #{build_path}"

  exec_path = "/usr/local/ruby-enterprise"
  install_path = "/usr/local/ruby-enterprise-#{version}"
  binaries = %w(erb gem irb passenger-config passenger-install-apache2-module passenger-make-enterprisey passenger-memory-stats passenger-spawn-server passenger-status passenger-stress-test rackup rails rake rdoc ree-version ri ruby testrb)
  source "http://rubyforge.org/frs/download.php/68719/ruby-enterprise-#{version}.tar.gz" do
    pre :prepare, "rm -rf #{build_path} || true"
    custom_install "sudo ./installer --auto=#{install_path}"

    post :install, "ln -sfn #{install_path} #{exec_path}"
    binaries.each {|bin| post :install, "ln -sfn #{exec_path}/bin/#{bin} /usr/local/bin/#{bin}" }
  end

  verify do
    has_directory install_path
    has_executable "#{install_path}/bin/ruby"
    binaries.each {|bin| has_symlink "/usr/local/bin/#{bin}", "#{install_path}/bin/#{bin}" }
  end
  
  # Add the exec_path to the PATH for the case of gems installed later not otherwise being on the PATH
  etc_profile = "/etc/profile"
  config = %Q(
# RubyEnterprise-path
export PATH=#{exec_path}/bin:$PATH
)

  post :install, push_text(config, etc_profile, :sudo => true)
  verify { file_contains etc_profile, "RubyEnterprise-path"}

  requires :ree_dependencies
end

package :ree_dependencies do 
  yum %w(make gcc-c++ zlib-devel openssl-devel readline-devel)
end
