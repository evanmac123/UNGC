namespace :maintenance do
  # the presence of a maintenance.html file in public/system will
  # trigger maintenance mode. See app/manifests/templates/passenger.vhost.erb

  desc "Enable maintenance mode"
  task :on do
    system "cp public/maintenance.html.off public/system/maintenance.html"
  end

  desc "Disable maintenance mode"
  task :off do
    system "rm ./public/system/maintenance.html"
  end

end
