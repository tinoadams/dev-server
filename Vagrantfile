# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Create and configure the VM(s)
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Assign a friendly name to this host VM
  config.vm.hostname = "dev-server"

  # Skip checking for an updated Vagrant box
  config.vm.box_check_update = false

  config.vm.box = "bento/ubuntu-16.04"
  config.vm.network "private_network", ip: "192.168.50.10"
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = true
  config.ssh.forward_agent = true

  config.vm.provision "docker"

  if Vagrant::Util::Platform.windows?
    ssh_files = ["id_rsa", "id_rsa.pub"]
    ssh_files.each { |x|
      location = File.join(Dir.home, ".ssh", x)
      if File.exists?(location)
          ssh_key = File.read(location)
          config.vm.provision :shell, :inline => "echo 'Windows-specific: Copying local #{x} to VM...' && mkdir -p /home/vagrant/.ssh && echo '#{ssh_key}' > /home/vagrant/.ssh/#{x} && chmod 600 /home/vagrant/.ssh/#{x} && chown vagrant:vagrant /home/vagrant/.ssh/#{x}"
      end
    }
  end

  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

  config.vm.provision "shell", inline: <<-SHELL
    # update OS and install other packages
    apt-get update
    apt-get upgrade -y
    apt-get install -y unzip jq htop

    # install samba home shares
    sudo apt-get install -y samba cifs-utils
    ln -sf /vagrant/configs/smb.conf /etc/samba/smb.conf
    sudo systemctl restart smbd

    # install nodejs
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs

    # install watchman
    git clone https://github.com/facebook/watchman.git
    pushd watchman/
    git checkout v4.7.0
    sudo apt-get install -y autoconf automake build-essential python-dev
    ./autogen.sh
    ./configure
    make
    sudo make install
    popd

    # install nuclide server
    sudo npm install -g nuclide

    # install hhvm
    sudo apt-get install software-properties-common
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
    sudo add-apt-repository "deb http://dl.hhvm.com/ubuntu xenial main"
    sudo apt-get update
    sudo apt-get install -y hhvm
    # configure hhvm
    ln -sf /vagrant/configs/hhvm.php.ini /etc/hhvm/php.ini
    ln -sf /vagrant/configs/hhvm.server.ini /etc/hhvm/server.ini
    # start hhvm on bootup and restart now
    sudo systemctl enable hhvm
    sudo systemctl restart hhvm

    #####
    #curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    # pushd /usr/local/bin
    # if [ ! -f terraform ]; then
    #   curl -o terraform.zip 'https://releases.hashicorp.com/terraform/0.9.4/terraform_0.9.4_linux_amd64.zip?_ga=2.99045149.280641089.1493945092-1985834203.1493706965'
    #   unzip terraform.zip && rm -f terraform.zip
    # fi
    # popd

    # add our shared bin dir to the path
    echo 'export PATH="/vagrant/bin:$PATH"' >> /etc/profile

    # ensure we source all login-scripts in the user bashrc
    su -l vagrant <<'EOF'
      echo 'for f in /vagrant/login-scripts/*.sh; do echo "Login script: $f" && source $f; done' >> ~/.bashrc
EOF
SHELL

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"
    vb.cpus = 2
  end
end
