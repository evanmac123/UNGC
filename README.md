# United Nations Global Compact

Welcome to the UNGC project, it was started in the summer of 2009 and is
currently maintained by:

* [Venu Keesari](https://github.com/vkeesari) &ndash; _**lead**_
* [Mattia Gheda](https://github.com/ghedamat)
* [Ben Moss](https://github.com/drteeth)

_A full list of contributors can be found
[here](https://github.com/unspace/UNGC/graphs/contributors)._

## Provisioning

If you are new to the project, you'll need to create an environment with the
necessary tools and dependencies installed before being able to run the
application. We use Vagrant to manage the VM and provide a clean terminal-based
development workflow, provisioning of the VM is automated. Use the following
steps to get up and running:

> Vagrant can be used with VMware Fusion (Mac) and VMware Workstation
> (Windows), visit the [Vagrant website](https://www.vagrantup.com/vmware) for
> more information.

1. Download the latest version of VirtualBox for your machine [here](https://www.virtualbox.org/wiki/Downloads)
2. Download the latest version of Vagrant for your machine [here](https://www.vagrantup.com/downloads.html)
3. Install a Git client like GitHub for [Windows](https://windows.github.com) or [Mac](https://mac.github.com)
4. Clone the repository onto your computer: `git clone git@github.com/unspace/ungc.git`
5. Copy the `Vagrantfile.example` file to `Vagrantfile`, you can modify this file
   for your specific needs, however, it should work without any modifications.
6. Open the project in your Terminal: `cd /the/place/where/i/cloned/ungc`
7. Run `vagrant up` to create the development environment
8. Run `vagrant reload` to refresh the newly created development VM

If Vagrant complains about being unable to mount the filesystem, the HGFS kernel
module fails to load, or that the Guest Additions are not up to date. You will
have to update them, if you're using VirtualBox, you can install the
`vagrant-vbguest` plugin which will keep them synchronized automatically, run
`vagrant plugin install vagrant-vbguest`, then try running `vagrant reload`
again. If you're using VMware, you can update the guest additions by following
the **Ubuntu Server** directions in
[this](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1022525)
VMware support article.

Once you've completed the above steps, you've successfully created a development
VM for working on the UNGC project. At this point you can log-in to the
development VM using the `vagrant ssh` command from within the project directory.

You can now use the following commands from within the UNGC project directory
for interacting with the VM:

* `vagrant halt` for shutting down the VM
* `vagrant up` for starting the VM
* `vagrant suspend` for suspending the VM state
* `vagrant resume` for resuming a suspended VM
* `vagrant ssh` for logging in to a running VM

Use the `vagrant help` command for more information about the above commands and
for a list of all available commands. You can also destroy the development VM at
any time using the `vagrant destroy` command, but this will also destroy any
data in the VM as well requiring you to reset the database again (see Database
below).

### VM Performance

It's important to note that the default performance for your development VM may
be unacceptable, you can change the number of virtual CPU cores and memory that
your VM will use from your Vagrantfile. If you're using VirtualBox uncomment and
change the settings under `config.vm.provider 'virtualbox'`, for VMware change
them under `config.vm.provider 'vmware_fusion'`. How much memory and how many
CPUs you should be using will depend on your host machine specs and your
utilization of RAM and CPU on your host machine. A general rule of thumb is
1/8<sup>th</sup> of your total RAM and as many CPUs as you have cores on your
host.

> UNGC likes RAM, 2048 MB is an ideal setting if you have the available memory.

File IO latency can also be quite poor when using VirtualBox out-of-the-box
(no pun intended). If you're using a host machine that supports NFS like OS X,
you can enable it based off of the instructions in the Vagrantfile.

### Connecting to Services Running in the VM

It is possible to directly connect to services running inside of the VM. You
can use tools such as [Sequel Pro](http://www.sequelpro.com/) and
[MySQL Workbench](http://dev.mysql.com/downloads/workbench/). The default
Vagrantfile forwards the ports for Redis, MySQL, and Rails (5000 in our case) to
your host machine as the same port number, this means you can seamlessly connect
to those services as if they were running directly on your host computer.

## Development

Once you have successfully provisioned a development VM using Vagrant or
whatever method you choose, you'll want to create a database and load it with
active data. Use the following steps to prepare the Rails application for
development:

1. Copy `config/database.yml.sample` to `config/database.yml`
2. Create a `tmp/pids` folder: `mkdir -p tmp/pids`
3. Log in to the VM, run `vagrant ssh` from within the project directory
4. Run `bundle` to download and install all Ruby dependencies
5. Ask [@ghedamat](https://github.com/ghedamat) or [@vkeesari](https://github.com/vkeesari) to add your Public Key to the production and staging servers
6. Run `rake db:reset_from_snapshot` to create the development and test databases defined in `config/database.yml` and seed them with data
7. Run `foreman start` to run the project

You're now ready to work on the UNGC project! From this point forward, you will
use `vagrant up`, `vagrant halt`, `vagrant ssh` to start, stop, and log-in to
the VM from within the project directory on your host machine.

You can edit the project source files from your favorite text editor on your
host machine, the project directory is mounted in the `/vagrant` folder of the
VM.

### Database

You can reset your development database at any time by running the
`rake db:reset_from_snapshot` task from within the project directory. You will
need to get your public SSH key added to the `~/.ssh/authorized_keys` file for
the `rails` user on `www.unglobalcompact.org`.

It's important to note that your local database must be using UTF-8 encoding, if
you're using the default `database.yml` file this will be the case. Otherwise
ensure that your `database.yml` contains the proper `encoding` and `collation`
values like this:

```yaml
development:
  adapter: mysql2
  database: myungcdb_development
  username: root
  encoding: utf8
  collation: utf8_general_ci
```

### Credentials

You can log into the app as an Organization or Admin user using the following
accounts:

| Role | Username | Password |
|------|----------|----------|
| Organization User | ungc341 | FE2EC4C8 |
| Admin User | keesari | compact2 |

### Search

UNGC uses Sphinx for search, it's installed by default in the Vagrant
development VM. If you'd prefer to install Sphinx manually you can follow
[these](http://freelancing-god.github.com/ts/en/installing_sphinx.html)
instructions.

UNGC also uses a library called [PDFMiner](http://euske.github.io/pdfminer/index.html)
for extracting text from PDF documents for use in searches. It is also installed
by default in the Vagrant development VM.

**In order to rebuild indexes and run the search service, use the following
commands:**

```
rake ts:rebuild RAILS_ENV=production
rake ts:start
```

### Debugging

We use [Byebug](https://github.com/deivid-rodriguez/byebug) for debugging since
the traditional `debugger` gem does not support Ruby 2. To use the Byebug
debugger, place `byebug` where you'd like to set a breakpoint, you can use the
`C` key to continue execution:

```ruby
def organization_type_name_for_custom_links
  byebug # execution will stop here and open the debugger
  if company?
    'business'
  elsif academic?
    'academic'
  elsif city?
    'city'
  else
    'non_business'
  end
end
```

## Deployment

UNGC is deployed using [Capistrano](https://github.com/capistrano/capistrano),
these are the available commands for deploying the application:

* `cap preview deploy` --- deploys from the preview branch
* `cap staging deploy` --- deploys from the staging branch
* `cap production deploy` --- deploys from production branch

You can see a list of all supported Capistrano tasks by running `cap -T` from
within the project directory.

### Scheduled Jobs

The application requires a daily scheduled cron job to notify organizations of
their COP submission deadline:

```
rails runner 'CopReminder.new.notify_all' RAILS_ENV=production
```

The application also requires a daily scheduled cron job to update
organizations' COP state:

```
rails runner 'CopStatusUpdater.new.update_all' RAILS_ENV=production
```

## Maintenance

### Updating COPs

Add a link to a COP:

```ruby
cop.cop_links.create(:url => 'http://www.ahkbrasil.com/', :attachment_type => 'cop', :language_id => 19)
```

Add a file to a COP:

```ruby
cop.cop_files.create(:attachment => File.new('/home/rails/ungc/uploaded/cops/COP.pdf'), :attachment_type => CopFile::TYPES[:cop], :language_id => 4)
```

### Adding Reports

Follow these steps while referring to existing reports:
For filenames, we usually named them same as the controller methods, but for Local Networks, you can choose a more friendly filename

1. Add your report query file to app/reports as a type of SimpleReport and assign the appropriate class name
2. Add corresponding method to controllers/admin/reports_controller.rb
3. Optional: add a view for your report in app/views/admin/reports
4. Add the report to the reports index screen app/views/admin/report/index.html.haml
5. If you are adding a Local Network report, prepend all names with `local_network`

### Adding A Section Banner

1. Save banner as PNG from Illustrator (use 10% opacity for logo when using blue background)
2. Note filename and add body class to application.css
3. Ex: body.environment #inner_head { background: url(/assets/banner_environment.png); }
4. For subsections, the class will be added after the previous classes in the body tag, so in the stylesheet, add the new class after the main section so it overrides the previous body class

```html
<body class="development editable_page environment environment_climate">
```

Example:

```css
body.environment #inner_head { background: url(/assets/banner_environment.png); }
body.environment_climate #inner_head { background: url(/assets/banner_environment_climate.png); }
```

Set `page.html_code` to the body class for the section you want the banner to
appear in.

### Fields To Delete

Here's a list of tables/fields that should be safe to delete after the
application has been launched:

* `*.old_id` - only used by importer
* `old_id` is still used in contacts.rb and test_helper.rb and should be changed to the id values
* `case_stories.status` - using state
* `case_stories.case_date` - using `updated_at`
* `country.manager_id` - used in transition, not used anymore
* `pages.top_level` - only used by importer

### Backups

To upgrade current version of JungleDisk:

```
sudo kill 'current process id'
curl -O http://downloads.jungledisk.com/jungledisk/junglediskserver_308-0_amd64.deb
sudo dpkg -i junglediskserver_308-0_amd64.deb
```

Server should start, if not, run:

```
sudo /usr/local/bin/junglediskserver
```

## Accounts & Services

These are the credentials to some external services used by the project for
monitoring and reporting:

| Service | Username | Password |
|---------|----------|----------|
| [Airbrake](https://unspaceungc.airbrake.io/) | keesari@unglobalcompact.org | airbrakeungc |
| [New Relic](https://login.newrelic.com/) | ungc@unspace.ca | newrelic |
