package :archivers do
  yum "rar unrar bzip2 gzip"

  verify do
    %w(rar unrar bzip2 gzip).each do |r|
      has_rpm r
    end
  end
end

package :gnupg do
  yum "gnupg"

  verify do
    has_rpm 'gnupg'
  end
end

package :gnupg2 do
  yum "gnupg2"

  verify do
    has_rpm 'gnupg2'
  end
end

package :duplicity do
  yum "duplicity"

  verify do
    has_rpm 'duplicity'
  end
  
  requires :yum_repository_epel
end

