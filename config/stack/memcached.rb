package :memcached_daemon, :provides => :memcached do
  description 'Memcached, a distributed memory object store'
  yum %w( memcached memcached-selinux )
  
  post :install, "sudo /sbin/service memcached start"
  post :install, "sudo ldconfig"
  
  verify do
    has_executable 'memcached'
  end
end

package :libmemcached do
  yum 'libmemcache libmemcache-devel'
  requires :yum_repository_rpmforge, :memcached_daemon
end
