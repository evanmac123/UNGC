# Moonshine_SSH

## A plugin for [Moonshine](http://github.com/railsmachine/moonshine)

This plugin provides a few security improvements for your default SSH
configuration. It also gives you the ability to easily customize your
settings. Browse through the sshd_config in the <tt>templates/</tt> directory
to see the available settings.

The new configuration file is tested before it's used, so there's less
chance that you'll accidentally lock yourself out.

### Instructions

* <tt>script/plugin install git://github.com/railsmachine/moonshine_ssh.git</tt>
* Edit moonshine.yml to customize plugin settings if desired:
    :ssh
      :port: 9022
      :allow_users:
        - rob
        - rails
* Include the plugin and recipe you in your manifest:
    recipe :ssh

### Authorized Keys

Puppet/ShadowPuppet has support for managing authorized keys like it does any other resource, but moonshine_ssh makes it simple to manage for your deploy user:

Edit moonshine.yml to include lines like:

    :ssh:
      :authorized_keys:
        user1@host:
          :type: ssh-rsa
          :key: KEY BODY GOES HERE
        user2@host:
          :type: ssh-rsa
          :key: KEY BODY GOES HERE

By default, this applies only to the deploy user, but you can apply it to others:

    :ssh:
      :authorized_keys:
        user1@host:
          :type: ssh-rsa
          :key: KEY BODY GOES HERE
          :user: uploads
    
If you ever need to remove a key, it's not as simple as removing the lines. You have to tell moonshine it needs to be removed:


    :ssh:
      :authorized_keys:
        user1@host:
          :type: ssh-rsa
          :key: KEY BODY GOES HERE
          :ensure: absent

### SFTP-only users

OpenSSH supports chrooting users natively. You can create users who will be chrooted
and only allowed to use SFTP (no console access) by adding the following to your 
moonshine.yml:

    :ssh:
      :sftponly: true

Then add this to your manifest:

    recipe :ssh
  
This creates a user called sftponly with a randomized password. To allow access, you can manag authorized_keys through your manifest:

    file '/home/sftponly/home/sftponly/.ssh/authorized_keys',
      :ensure => :present,
      :content => YOUR_SSH_PUBKEYS

Once connected via sftp, the user will be chrooted to /home/sftponly where they will only see a 
'home' directory. The user can upload files to /home/sftponly. For a normal user, the uploaded 
files will be located at /home/sftponly/home/sftponly.

#### Advanced

For a more complicated example, we'll consider a user called 'rob' who needs to upload 
files into a directory under the Rails application's shared/ directory. Since he will 
be chrooted, he can't have direct access to the directory. Also, the directory is owned 
by the rails group, so he'll need to be a member of that. Finally, we don't want to worry 
about public keys, so he'll need a password.

In your moonshine.yml:

    :ssh:
      :sftponly:
        :users: 
          :rob:
            :groups: rails
            :password: sooper_sekrit

In your manifest:

    recipe :ssh
    def mount_assets
      file '/home/rob/home/rob/assets', 
        :ensure => :directory, 
        :owner => 'rob',
        :require => file('/home/rob/home/rob')
        
      mount '/home/rob/home/rob/assets',
        :ensure => :mounted,
        :device => "#{configuration[:deploy_to]}/shared/assets/",
        :options => 'bind',
        :fstype => :none,
        :atboot => true,
        :remounts => true,
        :require => file('/home/rob/home/rob/assets')
    end
    recipe :mount_assets

Then deploy, and you're done! The user's /home/rob/assets directory is now actually the shared assets directory. Anything uploaded there will be available to the application automatically.

***
Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)

