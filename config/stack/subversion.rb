package :subversion, :provides => :scm do
  yum 'subversion'
  
  verify do
    has_executable 'svn'
  end
end
