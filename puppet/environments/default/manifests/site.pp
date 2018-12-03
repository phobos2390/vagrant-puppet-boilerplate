include 'people::user'

if versioncmp($::puppetversion, '3.6.1') >= 0 {
  Package {
    allow_virtual => true,
  }
}

$packages=lookup('packages')

package { $packages:
  ensure => installed,
}

$repos=lookup('repos')
$repodefaults=lookup('repo-defaults')

create_resources(vcsrepo,$repos,$repodefaults)

exec { "Install-Dotfiles":
  command => "/bin/sh ./install.sh",
  user => "vagrant",
  cwd => "/home/vagrant/phobos2390/dotfiles",
  creates => "/home/vagrant/.dotfiles/",
  require => Vcsrepo["/home/vagrant/phobos2390/dotfiles"],
}

