require 'spec_helper_acceptance'

describe 'puppetdeploy' do
  context 'all in one' do
    it 'performs setup' do
      # Create ssh keys for foreman and puppet, format the public keys for
      # consumption by ssh_authorized_key
      shell 'ssh-keygen -N "" -f /tmp/puppet'
      shell 'ssh-keygen -N "" -f /tmp/jenkins'
      shell 'awk \'{ printf $2; }\' /tmp/puppet.pub > /tmp/puppet.pub.1'
      shell 'awk \'{ printf $2; }\' /tmp/jenkins.pub > /tmp/jenkins.pub.1'
      # Mimick a foreman install
      shell 'mkdir -p /var/lib/jenkins'
      shell 'useradd -m -d /var/lib/jenkins -s /bin/bash jenkins'
    end
    it 'provisions with no errors' do
      pp = <<-EOS
        class { 'puppetdeploy':
          is_jenkins          => true,
          is_puppet_ca        => true,
          is_puppet_master    => true,
          jenkins_private_key => file('/tmp/jenkins'),
          jenkins_public_key  => file('/tmp/jenkins.pub.1'),
          puppet_private_key  => file('/tmp/puppet'),
          puppet_public_key   => file('/tmp/puppet.pub.1'),
          puppet_masters      => [
            'test',
          ],
        }
      EOS
      # Check for clean provisioning and idempotency
      apply_manifest pp, :catch_failures => true
      apply_manifest pp, :catch_changes => true
    end
    it 'allows ssh connection as jenkins' do
      shell 'sudo -u jenkins -H -s ssh -oStrictHostKeyChecking=no puppet@localhost true', :acceptable_exit_codes => 0
    end
    it 'allows ssh connection as puppet' do
      shell 'sudo -u puppet -H -s ssh -oStrictHostKeyChecking=no puppet@localhost true', :acceptable_exit_codes => 0
    end
  end
end
