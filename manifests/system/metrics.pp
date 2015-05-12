#
# [notification_type] Type used to write notifications. Currnetly only supports
# log.
#
class rjil::system::metrics(
  $notification_type = 'log',
  $log_file          = '/usr/lib/jiocloud/metrics/collectd_notifications.log',
) {

  # remove all default plugins so that we can fully customize
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }

  # write data to csv files
  file { ['/var/lib/metrics', '/var/lib/metrics/collectd', '/var/lib/metrics/collectd/csv', '/usr/lib/jiocloud/metrics']:
    ensure => directory,
  }

  class { 'collectd::plugin::csv':
    datadir    => '/var/lib/metrics/collectd/csv',
    storerates => false,
  }

  file { '/etc/collectd/conf.d/20-notifications.conf':
    content => template("rjil/collectd/${notification_type}_notifications.conf.erb"),
    notify  => Service['collectd'],
    require => File['/usr/lib/jiocloud/metrics'],
  }

  include collectd::plugin::memory
  #include collectd::plugin::thresold

  class { 'collectd::plugin::df':
    valuespercentage => true
  }

  #register df thresold
  rjil::system::define_metrics { 'df':
    instance          => 'free',
    persist           => 'True',
    persistok         => 'True',
    disks             => ['root'],
    disk_percent_warn => '10',
    disk_percent_fail => '5',
  }
  #register memory thresold
  rjil::system::define_metrics { 'memory':
    instance    => 'free',
    persist     => 'True',
    persistok   => 'True',
    memory_warn => '100000',
  }


}
