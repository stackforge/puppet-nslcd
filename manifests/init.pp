# Copyright 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: nslcd
#
class nslcd (
    $use_ldap    = true,
    $uri         = '',
    $base        = '',
    $ssl         = 'yes',
    $tls_reqcert = 'allow',
    $scope       = 'sub',
    $map         = 'passwd uid',
) {

  # install package depending on OS
  $packagename = $::osfamily ? {
    'RedHat' => 'nss-pam-ldapd',
    'debian' => 'nslcd',
    default  => 'nslcd',
  }

  if $use_ldap != false {
    package { $packagename: ensure => present }

    file { '/etc/nslcd.conf':
      ensure => present,
      owner  => 'root',
      group  => 'nslcd',
      mode   => '0640',
      content => template('nslcd/nslcd.conf.erb'),
    }
    service { 'nscd':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  =>  File['/etc/nslcd.conf'],
    }
    service { 'nslcd':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  =>  File['/etc/nslcd.conf'],
    }
  } else {
    if defined(Service['nslcd']) {
      service { 'nslcd':
        ensure => stopped,
        enable => false,
      }
    }
    package { $packagename: ensure => absent }
  }

}
