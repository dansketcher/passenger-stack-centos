# c.f: http://andrewduck.name/2009/01/imagemagick-64x-on-centos-5/  
package :imagemagick do
  description 'ImageMagick'
  version 'ImageMagick-6.6.0-5' # 'ImageMagick-6.6.*'
  
  source  "ftp://mirror.aarnet.edu.au/pub/imagemagick/#{version}.tar.bz2" do
    prefix '/usr'
    custom_install "./configure --prefix=/usr --with-bzlib=yes --with-fontconfig=yes --with-freetype=yes --with-gslib=yes --with-gvc=yes --with-jpeg=yes --with-jp2=yes --with-png=yes --with-tiff=yes && make && make install"
    post :install, "sudo /sbin/ldconfig /usr/"
  end
  
  verify do
    has_file '/usr/bin/Magick-config'
  end
  
  requires :imagemagick_dependencies, :build_essential
end

package :imagemagick_dependencies do
  yum "ImageMagick ImageMagick-devel" do
    post :install, "sudo yum erase ImageMagick ImageMagick-devel -y"
    post :install, "sudo yum install tcl-devel libpng-devel libjpeg-devel ghostscript-devel bzip2-devel freetype-devel libtiff-devel -y"
  end

  verify do
    %w(tcl-devel libpng-devel libjpeg-devel ghostscript-devel bzip2-devel freetype-devel libtiff-devel).each do |r|
      has_rpm r
    end
  end

  requires :yum_repository_epel, :yum_repository_rpmforge
end

package :rmagick do
  description 'Ruby RMagick gem'
  gem 'rmagick'
  version '2.12.2'
  
  verify do
    has_gem 'rmagick'
  end
  
  requires :imagemagick, :ruby_enterprise
end
