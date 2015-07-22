require 'beaker-rspec'

config = {
  'main' => {
    'logdir' => '/var/log/puppet',
    'vardir' => '/var/lib/puppet',
    'ssldir' => '/var/lib/puppet/ssl',
    'rundir' => '/var/run/puppet',
  },
}

# Install latest puppet from puppetlabs.com
on hosts, install_puppet
# Explicitly configure puppet to avoid warnings
configure_puppet(config)

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    # Install this module for testing
    puppet_module_install(:source => module_root, :module_name => 'puppetdeploy')
    # Install common master/agent deps
    on hosts, puppet('module', 'install', 'spjmurray-lsyncd'), { :acceptable_exit_codes => [0,1] }
  end
end
