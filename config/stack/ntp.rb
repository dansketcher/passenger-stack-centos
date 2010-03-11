package :ntp do
  description 'Network Time'
  yum 'ntp' do
    post :install, 'sudo /sbin/service ntpd start'
    post :install, 'sudo ln -fs /usr/share/zoneinfo/UTC /etc/localtime'
    post :install, 'sudo /usr/sbin/ntpdate -u -s 0.centos.pool.ntp.org 1.centos.pool.ntp.org 2.centos.pool.ntp.org'
    post :install, 'sudo /sbin/hwclock -w'
    post :install, 'sudo /sbin/chkconfig ntpd on'
  end
  
  verify do
    has_executable '/usr/sbin/ntpd'
  end
  
  requires :build_essential
end
