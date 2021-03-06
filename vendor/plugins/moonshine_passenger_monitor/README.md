# Moonshine_Passenger_Monitor

### A plugin for [Moonshine](http://github.com/railsmachine/moonshine)

This plugin provides a monitoring script to kill and log Passenger processes that are larger
than a specified size. The timing can also be adjusted based on when the cron job is set to run.

### Instructions

* rails 2: <tt>script/plugin install git://github.com/railsmachine/moonshine_passenger_monitor.git</tt>
* rails 3: <tt>rails plugin install git://github.com/railsmachine/moonshine_passenger_monitor.git</tt>

* Edit moonshine.yml to customize plugin settings as desired:
    :passenger_monitor:
      # size in MB, 500 is the default
      :memory: 500
      
      # configure pattern to grep for based on app [Rack, pre-Rack, proctitle]
      # this plugin will attempt to set this for you, but can be set manually
      
      # Rack
      # :pattern: 'Rack: /srv/yourapp/current'
      
      # pre-Rack
      # :pattern: 'Rails: /srv/yourapp/current'
      
      # proctitle, port can be set or defaults to 80
      # :pattern:  current [yourapp/80]

* Include the plugin and recipe in your manifest:
    recipe :passenger_monitor
    
Deploy and done!

***

Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)
