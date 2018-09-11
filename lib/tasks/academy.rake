# frozen_string_literal: true

namespace :academy do

  desc "Import courses and enrollments"
  task import: :environment do
    importer = Academy::CourseImporter.new
    importer.authenticate
    importer.import_courses
    importer.import_enrollments
  end

  desc "Generate username/passwords for all non-login roles from Participant level Organizations."
  task invite_non_login_participants: :environment do
    organizations = Organization.active.participants.participant_level
    contacts = Contact.joins(:organization)
                 .where(organization: organizations)
                 .where(username: nil, encrypted_password: nil)

    contacts.each do |c|
      Academy::ViewerInvitationJob.perform_later(c)
    end
  end

end
