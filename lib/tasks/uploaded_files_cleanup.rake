desc 'Get rid of files uploaded during organization signup and never attached'
task :uploaded_files_cleanup => :environment do |t|
  UploadedFile.where("attachable_key = 'legal_status' and attachable_id is null and updated_at < ?", Date.today - 1.week).destroy_all
end
