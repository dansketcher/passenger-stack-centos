package :git, :provides => :scm do
  description 'Git from EPEL'
  yum 'git'
  requires :yum_repository_epel
end

package :gitosis do
  description 'Gitosis server'
  yum 'gitosis'
  requires :yum_repository_epel
end
