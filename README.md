# United Nations Global Compact

# Accounts

## Airbrake
`https://unspaceungc.airbrake.io/`
user: `keesari@unglobalcompact.org`
password: `airbrakeungc`

## NewRelic RPM
URL: `https://rpm.newrelic.com`
user: `ungc@unspace.ca`
password: `newrelic`

## App
Organization user / pass:
`ungc341` / `FE2EC4C8`

Admin user / pass:
`keesari` / `compact2`

# Data Migration
The data from the current production database can be imported by taking a dump of the production database using
the mysqldump command. You'll need to get access to the machine running the production application. This can be done by
SSHing to rails@unglobalcompact.org. You will need to get your public SSH key added to the `~/.ssh/authorized_keys`
file for the rails user on `unglobalcompact.org`. Once you have access use the `rake db:reset_from_snapshot` command to get a
snapshot of the current production database.  This will copy this file to your machine using `scp` for you.

Make sure your database is using the correct encoding:
`mysql -u root -e CREATE DATABASE unglobalcompact CHARACTER SET utf8 COLLATE utf8_general_ci;`

# Application setup

## Get the essentials
GIT: `sudo apt-get install git`

## Make sure you run Ruby 2.1.3!
[RVM](http://rvm.beginrescueend.com/) - makes installing multiple Ruby versions extremely easy.
`bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )`
`rvm install 2.1.3`
`rvm use 2.1.3` this will download and install ruby 2.1.3
`rvm 2.1.3 --default` this will make the downloaded 2.1.3 the default in your computer
`cap staging ruby:upgrade` this will upgrade the version of ruby on the staging machine

## Redis
UNGC uses redis 2.6+ for background jobs and soon as a session store. Sidekiq is used to interface with redis from the ruby side and runs alongside rails.  To enable working with this in development, use the `foreman` gem to start both rails and sidekiq. Specific instructions follow below.

## Installing Redis
`sudo apt-get install python-software-properties`
`sudo add-apt-repository ppa:chris-lea/redis-server`
`sudo apt-get update`
`sudo apt-get install redis-server`

OR

[rbenv](htpt://https://github.com/sstephenson/rbenv) - another option for managing multiple Rubies

At this point, you get new executables for `gem`, `irb` and `ruby`, and have to install all gems again.
Make sure you never run the `sudo` command before installing any of the gems.

If you are setting up this application for the first time in you machine, follow the steps below:

`cp config/database.yml.sample config/database.yml`
`gem install bundler`
`bundle`
`rake db:create`
`rake db:migrate`
`rake db:seed`
`foreman start`

## Search requires:
- the Sphinx search engine, install version 0.9.9 from source:
[Install Sphinx](http://freelancing-god.github.com/ts/en/installing_sphinx.html)
- the Python library `pdfminer`, see this page for installation instructions:
[Install PDF Miner](http://www.unixuser.org/~euske/python/pdfminer/index.html)

Make sure that `pdf2txt.py` is in the path, and it should be fine.

Done :)

# Debugger
the traditional ruby debugger `debugger` no longer works with Ruby 2.x. We now use byebug (https://rubygems.org/gems/byebug).
byebug should work like the debugger in every other way.
[Using byebug]
place `byebug` at your breakpoint and press 'c' to continue execution

# Controlling Sphinx
`rake ts:rebuild RAILS_ENV=production`
`rake ts:start`

# Deploy with Capistrano

`cap -T` -- list out the available tasks
`cap preview deploy`  -- deploys from the preview branch
`cap staging deploy`  -- deploys from the staging branch
`cap production deploy`  -- deploys from production branch

# Cron Jobs
The application needs a cron job to notify organizations of their COP submission deadline - this needs to run daily.
`rails runner 'CopReminder.new.notify_all' RAILS_ENV=production`

The application needs a cron job to update organizations' COP state - this needs to run daily.
`rails runner 'CopStatusUpdater.new.update_all' RAILS_ENV=production`

# COP Maintenance
`cop.cop_links.create(:url => 'http://www.ahkbrasil.com/', :attachment_type => 'cop', :language_id => 19)`
`cop.cop_files.create(:attachment => File.new('/home/rails/ungc/uploaded/cops/COP.pdf'), :attachment_type => CopFile::TYPES[:cop], :language_id => 4)`

# Adding a new Report
Follow these steps while referring to existing reports:
For filenames, we usually named them same as the controller methods, but for Local Networks, you can choose a more friendly filename

1. Add your report query file to app/reports as a type of SimpleReport and assign the appropriate class name
2. Add corresponding method to controllers/admin/reports_controller.rb
3. Optional: add a view for your report in app/views/admin/reports
4. Add the report to the reports index screen app/views/admin/report/index.html.haml
5. If you are adding a Local Network report, prepend all names with `local_network`

# Adding a new section banner
1. Save banner as PNG from Illustrator (use 10% opacity for logo when using blue background)
2. Note filename and add body class to application.css
3. Ex: body.environment #inner_head { background: url(/assets/banner_environment.png); }
4. For subsections, the class will be added after the previous classes in the body tag, so in the stylesheet, add the new class after the main section so it overrides the previous body class

`<body class="development editable_page environment environment_climate">`


Example:

`body.environment #inner_head { background: url(/assets/banner_environment.png); }`

`body.environment_climate #inner_head { background: url(/assets/banner_environment_climate.png); }`


Set `page.html_code` to the body class for the section you want the banner to appear in

# Fields to delete
Here's a list of tables/fields that should be safe to delete after the application has been launched:

*.old\_id - only used by importer

old\_id is still used in contacts.rb and test_helper.rb and should be changed to the id values

case\_stories.status - using state
case\_stories.case\_date - using updated\_at
country.manager\_id - used in transition, not used anymore
pages.top\_level - only used by importer

# Server Backup
To upgrade current version of JungleDisk
`sudo kill 'current process id'`
`curl -O http://downloads.jungledisk.com/jungledisk/junglediskserver_308-0_amd64.deb`
`sudo dpkg -i junglediskserver_308-0_amd64.deb`

Server should start, if not:
`sudo /usr/local/bin/junglediskserver`
