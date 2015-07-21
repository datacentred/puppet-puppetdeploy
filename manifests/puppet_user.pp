# == Class: puppetdeploy::puppet_user
#
# Manages the puppet user account to allow operation
#
class puppetdeploy::puppet_user {

  # The puppet CA need a shell to accept push request from the continuous
  # delivery server.  Puppet slaves need to accept rsync+ssh requests from
  # the deploy master.
  if $puppetdeploy::is_puppet_ca or $puppetdeploy::is_puppet_master {

    user { 'puppet':
      ensure => present,
      shell  => '/bin/bash',
    }

  }

  # The CA needs the private key to talk to the masters
  if $puppetdeploy::is_puppet_ca {

    # ~/.ssh is implicitly created on slaves by ssh_authorized_key
    file { '/var/lib/puppet/.ssh':
      ensure => directory,
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0700',
    } ->

    file { '/var/lib/puppet/.ssh/id_rsa':
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0600',
      content => $puppetdeploy::puppet_private_key,
    }

  }

  # Masters need the public key to accept SSH from the CA
  if $puppetdeploy::is_puppet_master {

    ssh_authorized_key { 'puppet':
      user => 'puppet',
      type => 'ssh-rsa',
      key  => $puppetdeploy::puppet_public_key,
    }

  }

}
