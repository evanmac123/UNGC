desc 'Get rid of files uploaded during organization signup and never attached'
task :uploaded_files_cleanup => :environment do |t|
  UploadedFile.where("attachable_key = 'legal_status' and attachable_id is null").destroy_all
end
