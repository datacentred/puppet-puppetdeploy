# == Class: puppetdeploy
#
# Puppet code deployment helper classes.
#
# === Description
#
# This module is intended for use in HA environments where Jenkins or a similar
# CD solution pushes puppet code updates to the puppetca, which is then
# responsible for propagating the changes across a cluster of puppet master
# nodes.
#
# === Details
#
# ==== Puppet User Accounts
#
# On the CA and master nodes puppet code is all managed by the puppet user and
# group.  As such it depends on the puppet module being installed to implicitly
# create the user and group.  This class modifies the user to add a unix shell
# which enables the CA to SSH into the masters to synchronize environments and
# the CI server to push changes to the CA over SSH.
#
# ==== SSH Keys
#
# To facilitate passwordless SSH code replication the CA node needs a private
# SSH key installing and masters need the authorized public key adding.  The
# CD server again needs a private key installing and the corresponding public
# key authorizing on the puppet CA.
#
# ==== Code Replication
#
# Code replication duties are handled by lsyncd via rsync over SSH. Note that
# on older operating systems e.g. Ubuntu 14.04 fs.inotify.max_user_watches is
# set to 8192 so may need to be updated to allow support for more files.
#
# === Parameters
#
# [*is_jenkins*]
#   Is this a Jenkins node
#
# [*is_puppet_ca*]
#   Is this a Puppet CA node
#
# [*is_puppet_master*]
#   Is this a Puppet master node
#
# [*jenkins_private_key*]
#   Private key to be installed on the Jenkins host
#
# [*jenkins_public_key*]
#   Jenkins public key to be installed on the Puppet CA
#
# [*puppet_private_key*]
#   Private key to be installed on the Puppet CA
#
# [*puppet_public_key*]
#   Puppet public key to be installed on the Puppet masters
#
# [*puppet_master*]
#   Puppet masters to synchronise puppet code to
#
class puppetdeploy (
  $is_jenkins = false,
  $is_puppet_ca = false,
  $is_puppet_master = false,
  $jenkins_private_key = undef,
  $jenkins_public_key = undef,
  $puppet_private_key = undef,
  $puppet_public_key = undef,
  $puppet_masters = undef,
) {

  include ::puppetdeploy::puppet_user
  include ::puppetdeploy::jenkins_user
  include ::puppetdeploy::lsyncd

  Class['::puppetdeploy::puppet_user'] ->
  Class['::puppetdeploy::lsyncd']

}
