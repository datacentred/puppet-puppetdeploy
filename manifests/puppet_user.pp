# == Class: puppetdeploy::puppet_user
#
# Manages the puppet user account to allow operation
#
class puppetdeploy::puppet_user {

#  # The puppet CA need a shell to accept push request from the continuous
#  # delivery server.  Puppet slaves need to accept rsync+ssh requests from
#  # the deploy master.
#  if $puppetdeploy::is_puppet_ca or $puppetdeploy::is_puppet_master {
#
#    user { 'puppet':
#      ensure => present,
#      shell  => '/bin/bash',
#    }
#
#  }

  # The CA needs the private key to talk to the masters
  if $puppetdeploy::is_puppet_ca {

    # ~/.ssh is implicitly created on slaves by ssh_authorized_key
    file { '/opt/puppetlabs/server/data/puppetserver/.ssh':
      ensure => directory,
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0700',
    } ->

    file { '/opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa':
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0600',
      content => $puppetdeploy::puppet_private_key,
    } ->

    ssh_config { 'puppetdeploy disable strict host checks':
      host   => "puppet*.${::domain}",
      key    => 'StrictHostKeyChecking',
      value  => 'no',
      target => '/opt/puppetlabs/server/data/puppetserver/.ssh/config',
    }

  }

  # Masters need the public key to accept SSH from the CA
  if $puppetdeploy::is_puppet_master {

    ssh_authorized_key { 'puppet':
      user => 'puppet',
      type => 'ssh-rsa',
      key  => $puppetdeploy::puppet_public_key,
    }

    ensure_packages('rsync')

  }

}
