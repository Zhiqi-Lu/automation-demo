VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.define "vip01" do |vip01|
    vip01.vm.box = "ubuntu/bionic64"
    vip01.vm.hostname = "vip01"
    vip01.vm.network :private_network, ip: "10.11.12.41"
    vip01.vm.network :private_network, ip: "192.168.12.41", virtualbox__intnet: true
  end 

  config.vm.define "vip02" do |vip02|
    vip02.vm.box = "ubuntu/bionic64"
    vip02.vm.hostname = "vip02"
    vip02.vm.network :private_network, ip: "10.11.12.42"
    vip02.vm.network :private_network, ip: "192.168.12.42", virtualbox__intnet: true
  end

  config.vm.define "server01" do |server01|
    server01.vm.box = "ubuntu/bionic64"
    server01.vm.hostname = "server01"
    server01.vm.network :private_network, ip: "10.11.12.51"
    server01.vm.network :private_network, ip: "192.168.12.51", virtualbox__intnet: true
  end

  config.vm.define "server02" do |server02|
    server02.vm.box = "ubuntu/bionic64"
    server02.vm.hostname = "server02"
    server02.vm.network :private_network, ip: "10.11.12.52"
    server02.vm.network :private_network, ip: "192.168.12.52", virtualbox__intnet: true
  end

#  config.vm.define "db01" do |db01|
#    db01.vm.box = "ubuntu/bionic64"
#    db01.vm.hostname = "db01"
#    db01.vm.network :private_network, ip: "10.11.12.61"
#    db01.vm.network :private_network, ip: "192.168.12.61", virtualbox__intnet: true
#  end
#
#  config.vm.define "db02" do |db02|
#    db02.vm.box = "ubuntu/bionic64"
#    db02.vm.hostname = "db02"
#    db02.vm.network :private_network, ip: "10.11.12.62"
#    db02.vm.network :private_network, ip: "192.168.12.62", virtualbox__intnet: true
#  end
#
#  config.vm.define "db03" do |db03|
#    db03.vm.box = "ubuntu/bionic64"
#    db03.vm.hostname = "db03"
#    db03.vm.network :private_network, ip: "10.11.12.63"
#    db03.vm.network :private_network, ip: "192.168.12.63", virtualbox__intnet: true
#  end

end
