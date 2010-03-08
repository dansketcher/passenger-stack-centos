package :subversion, :provides => :scm do
  yum 'subversion'
  
  verify do
    has_executable 'svn'
  end
end

package :apache_mod_dav_svn do
  yum "mod_dav_svn"

  verify do
    has_file '/etc/httpd/conf.d/subversion.conf'
  end

  requires :apache
end
