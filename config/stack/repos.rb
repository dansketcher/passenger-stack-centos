package :yum_repository_pgdg do
  version 'pgdg-centos-8.4-1'
  
  rpm "http://yum.pgsqlrpms.org/reporpms/8.4/#{version}.noarch.rpm"

  verify do
    has_rpm version
  end
end

package :yum_repository_rpmforge do
  version 'rpmforge-release-0.5.1-1.el5.rf'

  rpm "http://rpmforge.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/#{version}.`uname -i`.rpm"

  verify do
    has_rpm version
  end
end

package :yum_repository_epel do
  version 'epel-release-5-3'
  
  rpm "http://download.fedora.redhat.com/pub/epel/5/i386/#{version}.noarch.rpm"

  verify do
    has_rpm version
  end
end

package :yum_repositories_external do
  post :install, 'yum clean all'
  post :install, 'yum makecache'

  verify do
    has_rpm 'pgdg-centos-8.4-1'
    has_rpm 'rpmforge-release-0.5.1-1.el5.rf'
    has_rpm 'epel-release-5-3'
  end

  requires :yum_repository_pgdg, :yum_repository_rpmforge, :yum_repository_epel
end
  
