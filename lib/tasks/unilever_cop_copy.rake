namespace :cop do

  desc "copy COPs from Unilever parent to subsidiary"
  task :unilever  => :environment do

    unilever = Organization.find_by(name: "Unilever")
    unilever_subsidiaries = [
      "Unilever Chile HPC Limitada",
      "Unilever de Argentina",
      "Unilever Ghana Limited",
      "Unilever Mocambique Lda.",
      "Unilever South Africa pty Ltd",
      "Unilever South Central Europe",
      "Unilever South East Africa",
      "Unilever Vietnam",
      "PT. Unilever Indonesia Tbk.",
      "Hindustan Unilever Limited",
      "Unilever Myanmar Limited",
      "Unilever Sanayi ve Ticaret Turk A.S."
    ]
    unilever_cops(from: unilever, to: unilever_companies(unilever_subsidiaries))

    puts
    puts 'Unilever COPs are now copied'
    puts
  end

  def unilever_companies(subsidiary_names)
    subsidiaries = subsidiary_names.map do |name|
      puts name
      Organization.find_by!(name: name)
    end

    subsidiaries
  end

  def unilever_cops(from:, to:)
    # for each subsidiary, create a new COP that is a copy of the unilever COP.
    # also, copy all the cop answers, links and files while you are there.
    subsidiaries = to

    Organization.transaction do
      unilever_cop = from.communication_on_progresses.first

      attrs = unilever_cop.attributes
      attrs.delete("id")
      attrs.delete("organization_id")

      subsidiaries.each do |subsidiary|
        subsidiary_cop = subsidiary.communication_on_progresses.create!(attrs)

        unilever_cop.cop_answers.each do |answer|
          answer_attrs = answer.attributes
          answer_attrs.delete("id")
          answer_attrs.delete("cop_id")

          subsidiary_cop.cop_answers.create!(answer_attrs)
        end

        unilever_cop.cop_links.each do |link|
          link_attrs = link.attributes
          link_attrs.delete("id")
          link_attrs.delete("cop_id")

          subsidiary_cop.cop_links.create!(link_attrs)
        end

        unilever_cop.cop_files.each do |file|
          file_attrs = file.attributes
          file_attrs.delete("id")
          file_attrs.delete("cop_id")

          # create a new CopFile and also cop the file on disk
          new_file = subsidiary_cop.cop_files.create!(file_attrs)
          new_file.attachment = file.attachment
          new_file.save!
        end
      end
    end
  end
end
