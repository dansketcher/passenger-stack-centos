package :build_essential do
  description 'Build tools'
  yum 'build-essential' do
    pre :install, 'yum -y update'
    pre :install, 'sudo /sbin/service yum-updatesd start'
    post :install, 'sudo /sbin/chkconfig yum-updatesd on'
  end
end
