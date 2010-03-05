package :yum_repository_pgdg do
  version 'pgdg-centos-8.4-1'
  
  source "http://yum.pgsqlrpms.org/reporpms/8.4/#{version}.noarch.rpm" do
    custom_install "sudo rpm -ivh #{version}.noarch.rpm"
  end

  verify do
    has_rpm version
  end
end

package :yum_repository_rpmforge do
  version 'rpmforge-release-0.5.1-1.el5.rf'
  arch = 'x86_64'
  
  source "http://dag.wieers.com/rpm/packages/rpmforge-release/#{version}.#{arch}.rpm" do
    custom_install "sudo rpm -ivh #{version}.#{arch}.rpm"
  end

  verify do
    has_rpm version
  end
end

package :yum_repository_epel do
  version 'epel-release-5-3'
  
  source "http://download.fedora.redhat.com/pub/epel/5/i386/#{version}.noarch.rpm" do
    custom_install "sudo rpm -ivh #{version}.noarch.rpm"
  end

  verify do
    has_rpm version
  end
end
