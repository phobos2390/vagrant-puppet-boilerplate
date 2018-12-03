require 'pathname'
require 'fileutils'

home_ssh = Pathname.new(File.expand_path('~') + '/.ssh')
pwd_ssh = Pathname.new(FileUtils.pwd() + '/.ssh')

if (!File.directory?(pwd_ssh))
  FileUtils.mkdir(pwd_ssh)
end

if (File.directory?(home_ssh))
  home_ssh.each_child do |file|
    if(file.basename() != 'authorized_keys' &&
      !File.exists?(pwd_ssh + file.basename()))
      puts "Moving #{file} to #{pwd_ssh}"
      FileUtils.cp(file, pwd_ssh)
    end
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider :virtualbox do |vb|
    vb.memory = 4096
  end

  config.vm.provision :shell, name: "Setup-Puppet", privileged: true, inline: <<-SHELL
    mkdir -p /usr/local/rvm
    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -L get.rvm.io | bash -s stable --path /usr/local/rvm
    [ -f /etc/profile.d/rvm.sh ] && source /etc/profile.d/rvm.sh
    [ -f /home/vagrant/.rvm/scripts/rvm ] && source /home/vagrant/.rvm/scripts/rvm
    [ -f /home/vagrant/.rvm/scripts/rvm ] && source /home/vagrant/.rvm/scripts/rvm
    rvm reload
    rvm requirements run
    rvm install 2.5
    yum install -y git
    git clone --recursive https://github.com/hashicorp/puppet-bootstrap.git /tmp/puppet-bootstrap
    if [ -d /tmp/puppet-bootstrap ]; then
      pushd /tmp/puppet-bootstrap
      sudo sh ./centos_7_x.sh
      popd
      rm -rf /tmp/puppet-bootstrap
    fi
    #sudo rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
    gem install puppet -v '~> 5.0' --no-rdoc --no-ri
    gem install librarian-puppet -v '~> 3.0' --no-rdoc --no-ri
  SHELL

  config.vm.synced_folder ".","/vagrant", type: "rsync"
  config.vm.synced_folder "puppet/environments","/tmp/vagrant-puppet/environments", type: "rsync"

  config.vm.provision :shell, name: "Puppet-librarian", privileged: false, inline: <<-SHELL
    cd /vagrant/puppet/environments/default/
    if [ ! -e Puppetfile.lock -o Puppetfile.lock -ot Puppetfile ]; then
      chmod -R a+rw modules
      librarian-puppet install
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
