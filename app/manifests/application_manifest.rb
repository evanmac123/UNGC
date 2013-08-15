require "#{File.dirname(__FILE__)}/../../vendor/plugins/moonshine/lib/moonshine.rb"
class ApplicationManifest < Moonshine::Manifest::Rails
  include Moonshine::Dnsmasq
  # The majority of your configuration should be in <tt>config/moonshine.yml</tt>
  # If necessary, you may provide extra configuration directly in this class
  # using the configure method. The hash passed to the configure method is deep
  # merged with what is in <tt>config/moonshine.yml</tt>. This could be used,
  # for example, to store passwords and/or private keys outside of your SCM, or
  # to query a web service for configuration data.
  #
  # In the example below, the value configuration[:custom][:random] can be used in
  # your moonshine settings or templates.
  #
  # require 'net/http'
  # require 'json'
  # random = JSON::load(Net::HTTP.get(URI.parse('http://twitter.com/statuses/public_timeline.json'))).last['id']
  # configure({
  #   :custom => { :random => random  }
  # })

  # The default_stack recipe install Rails, Apache, Passenger, the database from
  # database.yml, Postfix, Cron, logrotate and NTP. See lib/moonshine/manifest/rails.rb
  # for details. To customize, remove this recipe and specify the components you want.
  recipe :default_stack
  recipe :god
  recipe :sphinx
  recipe :nodejs
  recipe :webdav
  recipe :ssh
  recipe :denyhosts
  recipe :dnsmasq
  recipe :resolv_conf

  on_stage(:production) do
    recipe :cron_tasks
    recipe :jungle_disk
    recipe :scout
  end

  def cron_tasks
     cron 'cop_state',
       :command => '/srv/unglobalcompact/current/script/cron/cop_state',
       :user => 'rails',
       :hour => 23,
       :minute => 0,
       :ensure => :present

     cron 'cop_reminder',
       :command => '/srv/unglobalcompact/current/script/cron/cop_reminder',
       :user => 'rails',
       :hour => 23,
       :minute => 10,
       :ensure => :present

     cron 'sphinx_index',
       :command => '/srv/unglobalcompact/current/script/cron/sphinx_index',
       :user => 'rails',
       :minute => 40,
       :ensure => :present

     cron 'start_mysqldump',
       :command => '/srv/unglobalcompact/current/script/cron/start_mysqldump',
       :user => 'rails',
       :hour => 5,
       :minute => 0,
       :ensure => :present

    cron 'stop_sphinx',
      :command => '/srv/unglobalcompact/current/script/cron/stop_sphinx',
      :user => 'rails',
      :hour => 6,
      :minute => 5,
      :ensure => :present

    cron 'searchable',
      :command => '/srv/unglobalcompact/current/script/cron/searchable',
      :user => 'rails',
      :hour => 6,
      :minute => 11,
      :ensure => :present

    cron 'sphinx_rebuild',
      :command => '/srv/unglobalcompact/current/script/cron/sphinx_rebuild',
      :user => 'rails',
      :hour => 6,
      :minute => 55,
      :ensure => :present

  end

  def jungle_disk
    deb_file = 'junglediskserver_316-0_amd64.deb'
    url = "https://downloads.jungledisk.com/jungledisk/#{deb_file}"

    exec 'download jungle_disk',
      :cwd => '/tmp',
      :command => "wget #{url}",
      :require => package('wget'),
      :creates => "/tmp/#{deb_file}"

    package 'junglediskserver',
      :provider => :dpkg,
      :ensure => :installed,
      :source => "/tmp/#{deb_file}",
      :require => exec('download jungle_disk')

    file '/etc/jungledisk/junglediskserver-license.xml',
      :ensure => :present,
      :owner => 'root',
      :notify => service('junglediskserver'),
      :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'junglediskserver-license.xml'), binding),
      :require => package('junglediskserver')

    file '/etc/jungledisk/junglediskserver-settings.xml',
      :ensure => :present,
      :owner => 'root',
      :notify => service('junglediskserver'),
      :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'junglediskserver-settings.xml'), binding),
      :require => package('junglediskserver')

    service 'junglediskserver',
      :provider => :init,
      :enable => true,
      :ensure => :running,
      :require => package('junglediskserver')
  end

  # Add your application's custom requirements here
  def application_packages
    # If you've already told Moonshine about a package required by a gem with
    # :apt_gems in <tt>moonshine.yml</tt> you do not need to include it here.
    # package 'some_native_package', :ensure => :installed

    # some_rake_task = "/usr/bin/rake -f #{configuration[:deploy_to]}/current/Rakefile custom:task RAILS_ENV=#{ENV['RAILS_ENV']}"
    # cron 'custom:task', :command => some_rake_task, :user => configuration[:user], :minute => 0, :hour => 0

    # %w( root rails ).each do |user|
    #   mailalias user, :recipient => 'you@domain.com', :notify => exec('newaliases')
    # end

    # farm_config = <<-CONFIG
    #   MOOCOWS = 3
    #   HORSIES = 10
    # CONFIG
    # file '/etc/farm.conf', :ensure => :present, :content => farm_config

    # Logs for Rails, MySQL, and Apache are rotated by default
    # logrotate '/var/log/some_service.log', :options => %w(weekly missingok compress), :postrotate => '/etc/init.d/some_service restart'

    # Only run the following on the 'testing' stage using capistrano-ext's multistage functionality.
    # on_stage 'testing' do
    #   file '/etc/motd', :ensure => :file, :content => "Welcome to the TEST server!"
    # end
  end
  # The following line includes the 'application_packages' recipe defined above
  recipe :application_packages

  def webdav
    a2enmod 'dav_fs'
    a2enmod 'dav'

    file "/etc/apache2/sites-available/webdav",
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'webdav.vhost.erb')),
      :owner => 'root',
      :ensure => :present,
      :notify => service('apache2')

    a2ensite 'webdav'
  end

end
