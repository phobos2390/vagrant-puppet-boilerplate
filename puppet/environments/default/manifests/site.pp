if versioncmp($::puppetversion, '3.6.1') >= 0 {
  Package {
    allow_virtual => true,
  }
}

$packages=hiera('packages')

package { $packages:
  ensure => installed,
}

$repos=hiera('repos')
$repodefaults=hiera('repo-defaults')

create_resources(vcsrepo,$repos,$repodefaults)

