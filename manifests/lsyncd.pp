# == Class: puppetdeploy::lsyncd
#
# Synchronises puppet configuration across the cluster
#
class puppetdeploy::lsyncd {

  if $puppetdeploy::is_puppetca {

    include ::lsyncd
    
    $lsyncd_targets = $puppetdeploy::puppet_masters

    lsyncd::process { 'puppetdeploy':
      content => template('puppetdeploy/puppet.lua.erb'),
      owner   => 'puppet',
      group   => 'puppet',
    }

  }

}
