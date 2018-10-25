Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider :virtualbox do |vb|
    vb.memory = 4096
  end

  config.vm.provision :shell, name: "Setup-Puppet", privileged: false, inline: <<-SHELL
    sudo yum install -y git
    git clone --recursive https://github.com/hashicorp/puppet-bootstrap.git /tmp/puppet-bootstrap
    if [ -d /tmp/puppet-bootstrap ]; then
      pushd /tmp/puppet-bootstrap
      sudo sh ./centos_7_x.sh
      popd
      rm -rf /tmp/puppet-bootstrap
    fi
    sudo gem install librarian-puppet -v '~> 2.2' --no-rdoc --no-ri
  SHELL

  config.vm.synced_folder ".","/vagrant", type: "rsync"
  config.vm.synced_folder "puppet/environments","/tmp/vagrant-puppet/environments", type: "rsync"

  config.vm.provision :shell, name: "Puppet-librarian", privileged: false, inline: <<-SHELL
    cd /vagrant/puppet/environments/default/
    if [ ! -e Puppetfile.lock -o Puppetfile.lock -ot Puppetfile ]; then
      chmod -R a+rw modules
      sudo /usr/local/bin/librarian-puppet install
#      [ $? -eq 0 ] && touch Puppetfile.lock
    else
      echo "Puppetfile is locked"
    fi
  SHELL
  
  config.vm.provision :puppet do |puppet|
    puppet.environment_path = "puppet/environments"
    puppet.environment = "default"
    puppet.hiera_config_path = "puppet/environments/default/hiera/hiera.yaml"
    puppet.facter = {
      "user" => "#{ENV['USER']}",
      "puppet_dir" => "/vagrant/puppet",
    }
  end

end
