package :memcached_daemon, :provides => :memcached do
  description 'Memcached, a distributed memory object store'
  yum %w( memcached )
  
  post :install, "sudo /sbin/service memcached start"
  post :install, "sudo ldconfig"
  
  verify do
    has_executable 'memcached'
  end
end

package :libmemcached do
  source 'http://download.tangent.org/libmemcached-0.25.tar.gz'
  requires :memcached_daemon
end
