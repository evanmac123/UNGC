namespace :cop do
  #Usage:
  #rake cop:copy["source","destination"]

  desc "copy COPs from one organization to another"
  task :copy, [:first_organization,:second_organization] => :environment do |t, args|
    arg1 = Organization.find_by!(name: args[:first_organization])
    arg2 = Organization.find_by!(name: args[:second_organization])

    clone_cops(from: arg1, to: arg2)

    puts
    puts 'COPs are now copied'
    puts
  end

  def clone_cops(from:, to:)
    Organization.transaction do
      from.communication_on_progresses.each do |source_cop|

        attrs = source_cop.attributes
        attrs.delete("id")
        attrs.delete("organization_id")

        new_cop = to.communication_on_progresses.create!(attrs)

        source_cop.cop_answers.each do |answer|
          answer_attrs = answer.attributes
          answer_attrs.delete("id")
          answer_attrs.delete("cop_id")

          new_cop.cop_answers.create!(answer_attrs)
        end

        source_cop.cop_links.each do |link|
          link_attrs = link.attributes
          link_attrs.delete("id")
          link_attrs.delete("cop_id")

          new_cop.cop_links.create!(link_attrs)
        end

        source_cop.cop_files.each do |file|
          file_attrs = file.attributes
          file_attrs.delete("id")
          file_attrs.delete("cop_id")

          new_file = new_cop.cop_files.create!(file_attrs)
          new_file.attachment = file.attachment
          new_file.save!
        end
      end
    end
  end
end
