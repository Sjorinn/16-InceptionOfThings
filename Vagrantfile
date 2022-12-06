Vagrant.configure("2") do |config|

  config.vm.define "pchambonS" do |pchambonS|
    pchambonS.vm.box = "generic/alpine317"
    pchambonS.vm.network "private_network", ip: "192.168.56.110"
    pchambonS.vm.provision "K3S Controller Mode", type: "shell", path: "K3SControllerMode.sh"
    pchambonS.vm.provider "virtualbox" do |vb|
      vb.name = "pchambonS"
      vb.memory = 1024
      vb.cpus = 1 
      end
  end

  config.vm.define "pchambonSW" do |pchambonSW|
    pchambonSW.vm.box = "generic/alpine317"
    pchambonSW.vm.network "private_network", ip: "192.168.56.111"
    pchambonSW.vm.provision "K3S Agent Mode", type: "shell", path: "K3SAgentMode.sh"
    pchambonSW.vm.provider "virtualbox" do |vb|
      vb.name = "pchambonSW"
      vb.memory = 1024
      vb.cpus = 1 
      end
  end

end
