package :yum_repository_pgdg do
  #  As per
  #  http://www.postgresonline.com/journal/index.php?/archives/144-An-almost-idiots-guide-to-Install-and-Upgrade-to-PostgreSQL-8.4-with-Yum.html
  #
  #  To get a list of postgresql related stuff:
  #  yum list | grep postgresql
  #
  #  If you see postgresql from other repositories besides pgdg84, then you need to exclude postgresql from coming from other repositories by following the below instructions excerpted from PostgreSQL How to Yum
  #
  #  * As root, cd /etc/yum.repos.d
  #
  #      * Edit distro's .repo file:
  #            o On Fedora, edit fedora.repo and fedora-updates.repo, [fedora] sections
  #            o On CentOS, edit CentOS-Base.repo, [base] and [updates] sections.
  #            o On Red Hat, edit edit /etc/yum/pluginconf.d/rhnplugin.conf [main] section.
  #                  + Add to the bottom of the section:
  #
  #                    exclude=postgresql*
  #
  
  version 'pgdg-centos-8.4-2'
  
  rpm "http://yum.pgrpms.org/reporpms/8.4/#{version}.noarch.rpm"
  
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
  noop do
    post :install, 'yum clean all'
    post :install, 'yum makecache'
    post :install, "sudo touch /etc/yum/yum_repositories_external"
  end

  verify do
    has_file '/etc/yum/yum_repositories_external'
  end

  requires :yum_repository_pgdg, :yum_repository_rpmforge, :yum_repository_epel
end
  
