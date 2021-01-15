BOX_IMG = "ubuntu/xenial64"
NODES_NUM = 2

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    end
  config.vm.define "master" do |subconfig|
    subconfig.vm.box = BOX_IMG
    subconfig.vm.hostname = "master"
    subconfig.vm.network :private_network, ip: "192.168.65.100"
    subconfig.vm.provision "shell", path: "scripts/install-all.sh"
    subconfig.vm.provision "shell", path: "scripts/install-master.sh"
    subconfig.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1800"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end

  (1..NODES_NUM).each do |i|
    config.vm.define "node#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMG
      subconfig.vm.hostname = "node#{i}"
      subconfig.vm.network :private_network, ip: "192.168.65.#{100+i}"
      subconfig.vm.provision "shell", path: "scripts/install-all.sh"
      subconfig.vm.provision "shell", path: "scripts/install-node.sh"
      subconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "1000"]
        vb.customize ["modifyvm", :id, "--cpus", "1"]
      end
    end
  end

  
end