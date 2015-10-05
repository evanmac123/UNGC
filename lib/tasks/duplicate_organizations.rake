require 'csv'

namespace :duplicate_organizations do

  desc "Rename duplicate, rejected organizations"
  task rename_rejected: [:environment] do
    duped = Organization.find_by_sql("select name from organizations group by binary name having count(name) > 1 order by binary name")

    filename = 'tmp/duplicate-organizations-renamed-rejected.csv'
    CSV.open(filename, 'w', :col_sep => "\t") do |line|
      duped.each do |dupe|
        line << %w(id name state cop_state created_at updated_at rejected_on)
        Organization.rejected.where(name: dupe.name).each_with_index do |o, i|
          if i > 0
            o.update!(name: "#{o.name}-duplicate#{i}")
          end
          line << [o.id, o.name, o.state, o.cop_state, o.created_at, o.updated_at, o.rejected_on]
        end
      end
    end

    puts "wrote #{filename}"
  end

  desc "Report on organizations blocking adding a unique constraint on name."
  task report: [:environment] do
    duped = Organization.find_by_sql("select name from organizations group by name having count(name) > 1 order by name")

    filename = 'tmp/duplicate-organizations.csv'
    CSV.open(filename, 'w', :col_sep => "\t") do |line|
      line << %w(id name state cop_state created_at updated_at rejected_on)
      duped.each do |dupe|
        Organization.where(name: dupe.name).each_with_index do |o, i|
          line << [o.id, o.name, o.state, o.cop_state, o.created_at, o.updated_at, o.rejected_on]
        end
      end
    end

    puts "wrote #{filename}"
  end

end
