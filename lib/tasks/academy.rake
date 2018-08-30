namespace :academy do

  desc "Import courses and enrollments"
  task import: :environment do
    importer = Academy::CourseImporter.new
    importer.authenticate
    importer.import_courses
    importer.import_enrollments
  end

end
