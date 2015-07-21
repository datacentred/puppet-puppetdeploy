# == Class: puppetdeploy::jenkins_user
#
# Manages the Jenkins user account to allow pushes to the deploy master
#
class puppetdeploy::jenkins_user {

  # The Jenkins server needs SSH access to the CA to allow pushes of updates
  if $puppetdeploy::is_jenkins {

    # ~/.ssh is implicitly created on the CA by ssh_authorized_key
    file { '/var/lib/jenkins/.ssh':
      ensure => directory,
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0700',
    } ->

    file { '/var/lib/jenkins/.ssh/id_rsa':
      ensure  => file,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0600',
      content => $puppetdeploy::jenkins_private_key,
    }

  }

  # The CA needs to allow communication from the Jenkins hosts
  if $puppetdeploy::is_puppet_ca {

    ssh_authorized_key { 'jenkins':
      user => 'puppet',
      type => 'ssh-rsa',
      key  => $puppetdeploy::jenkins_public_key,
    }

  }

}
