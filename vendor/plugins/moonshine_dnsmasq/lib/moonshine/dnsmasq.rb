module Moonshine
  module Dnsmasq
    
    def dnsmasq(options = {})
      configure(:dnsmasq => {})
      cache_size = configuration[:dnsmasq][:cache_size] || 256
      listen_address = configuration[:dnsmasq][:listen_address] || '127.0.0.1'
      servers = configuration[:dnsmasq][:servers] || ['8.8.8.8', '8.8.4.4', '208.67.222.222', '208.67.220.220']
      
      package 'dnsmasq',
        :ensure => :installed
        
      file '/etc/dnsmasq.conf',
        :ensure => :present,
        :owner => 'root',
        :mode => '744',
        :require => package('dnsmasq'),
        :notify => service('dnsmasq'),
        :content => template(File.join(File.dirname(__FILE__),'..','..','templates','dnsmasq.conf.erb'), binding)
      
      service 'dnsmasq',
        :require => package('dnsmasq'),
        :restart => '/etc/init.d/dnsmasq restart',
        :ensure => :running
      
    end
  
  end
end
