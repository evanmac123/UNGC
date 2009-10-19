namespace :scenarios do
  
  def simple_format(string)
    "<p>#{string.gsub(/\n/, "</p>\n<p>")}</p>"
  end
  
  desc 'Populate the events table with a bunch of random events'
  task :populate_events => :environment do
    require 'faker'
    countries = Country.all
    25.times do
      start_day = ((Date.today >> rand(12)) + rand(25))
      starts_on = Time.mktime start_day.year, start_day.month, start_day.day, 18, 0
      ends_on   = starts_on + rand(4).days
      Event.create :title => Faker::Lorem.words(4).join(' ').titleize,
        :description => simple_format(Faker::Lorem.paragraphs(4).join("\n")),
        :country_id  => countries[rand(countries.size)].id,
        :location    => Faker::Lorem.words(2).join(' ').titleize,
        :starts_on   => starts_on,
        :ends_on     => ends_on,
        :approved    => rand(4) >= 1
    end
  end
  
  desc 'Remove all events'
  task :remove_events => :environment do
    Event.delete_all
  end
end
