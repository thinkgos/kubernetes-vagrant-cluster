# -*- mode: ruby -*-
# vi: set ft=ruby :
# sync folder
# `vagrant plugin install vagrant-vbguest --plugin-version 0.21`` change synced_folder.type="virtualbox"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "centos/7"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.provider 'virtualbox' do |vb|
    #  sync time on host wake-up within VirtualBox
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
  end  
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    $num_instances = 3
    (1..$num_instances).each do |i|
      config.vm.define "node#{i}" do |node|
        node.vm.box = "centos/7"
        node.vm.box_version = "2004.01"
        node.vm.hostname = "k8s-node#{i}"
        ip = "192.168.56.#{i+100}"
        node.vm.network "private_network", ip: ip
        node.vm.provider "virtualbox" do |vb|
          vb.memory = "2048"
          vb.cpus = 2
          vb.name = "node#{i}"
        end
        # Enable provisioning with a shell script. Additional provisioners such as
        # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
        # documentation for more information about their specific syntax and use.
        node.vm.provision "shell", path: "bootstrap.sh", args: ["vagrant", "vagrant"] # user, group
        node.vm.provision "shell", path: "install.sh" , args: ["vagrant", "vagrant"] # user, group
        # config.vm.provision "shell", inline: <<-SHELL
        #   echo "hello world"
        # SHELL
      end
    end
end
