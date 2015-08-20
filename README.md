#Puppet Deploy

[![Build Status](https://travis-ci.org/spjmurray/puppet-puppetdeploy.png?branch=master)](https://travis-ci.org/spjmurray/puppet-puppetdeploy)

####Table Of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Usage](#usage)
4. [Dependencies](#dependencies)

##Overview

Manages accounts on Jenkins and across Puppet servers to allow synchronisation
of puppet environments across a cluster

##Module Description

This is intended for use with a Jenkins CI deployment server.  It installs a
private key SSH on Jenkins and public key on a Puppet CA.  Jenkins then pushes
environments to /etc/puppet/environments.  Lsyncd is deployed on the Puppet CA
to monitor for changes which it then propagates across the cluster.  This is
facilitated with RSync over SSH, for which the requisite keys are installed.

##Usage

###Jenkins CI Server

```puppet
class { 'puppetdeploy':
  is_jenkins          => true,
  jenkins_private_key => file('puppet:///modules/keys/jenkins_private_key'),
}
```

###Puppet CA Server

```puppet
class { 'puppetdeploy':
  is_puppet_ca       => true,
  jenkins_public_key => file('puppet:///modules/keys/jenkins_public_key'),
  puppet_private_key => file('puppet:///modules/keys/puppet_private_key'),
  puppet_masters     => [
    'puppet0',
    'puppet1',
    'puppet2',
  ],
}
```

###Puppet Master Server

```puppet
class { 'puppetdeploy':
  is_puppet_master  => true,
  puppet_public_key => file('puppet:///modules/keys/puppet_private_key'),
}
```

##Dependencies

- https://github.com/spjmurray/puppet-lsyncd
