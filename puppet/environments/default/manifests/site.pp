if versioncmp($::puppetversion, '3.6.1') >= 0 {
  Package {
    allow_virtual => true,
  }
}

$packages=hiera('packages')

package { $packages:
  ensure => installed,
}

