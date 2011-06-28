# Project-specific configuration for CruiseControl.rb
Project.configure do |project|
  # Send email notifications about broken and fixed builds to email1@your.site, email2@your.site (default: send to nobody)
  project.email_notifier.emails = ['keesari@unglobalcompact.org']
  # Set email 'from' field to john@doe.com:
  project.email_notifier.from = 'info@unglobalcompact.org'
end