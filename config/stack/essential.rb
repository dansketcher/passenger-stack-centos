package :build_essential do
  description 'Build tools'
  yum 'build-essential' do
    pre :install, 'yum -y update'
    pre :install, 'sudo /sbin/service yum-updatesd start'
  end
end
