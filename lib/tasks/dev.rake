namespace :dev do

  desc "seed the dev environment"
  task prime: [:environment, :"db:seed"] do
    if Rails.env.development?
      require "factory_bot"
      seed_staff_user
      action_platforms
    end
  end

  desc "copy cop files local"
  task :copy_cop_files, [:cop_id] => :environment do |t, args|
    id = args[:cop_id]
    cop = CommunicationOnProgress.find(id)
    cop.cop_files.each do |cop_file|
      local_path = cop_file.attachment.path
      FileUtils.mkdir_p(File.dirname(local_path))
      attachment_path = local_path.split("/public/system/").last
      remote_path = "/home/rails/site/public/system/#{attachment_path}"
      downloader = Downloader.new("unglobalcompact.org", "rails")
      downloader.download(from: remote_path, to: local_path)
      puts "\n"
    end
  end

  private

  def seed_staff_user
    Contact.find_by(username: "staff") || FactoryBot.create(:contact,
      username: "staff",
      password: "Passw0rd",
      organization: Organization.find_by(name: DEFAULTS[:ungc_organization_name])
    )
  end

  def action_platforms
    Rake::Task["action_platforms:create"]
  end

end
