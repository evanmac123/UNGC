namespace :scenarios do
  
  def simple_format(string)
    "<p>#{string.gsub(/\n/, "</p>\n<p>")}</p>"
  end
  
  def countries
    @countries ||= Country.all
  end
  
  def create_event(options={})
    defaults = {
      :title       => Faker::Lorem.words(4).join(' ').titleize,
      :description => simple_format(Faker::Lorem.paragraphs(4).join("\n")),
      :country_id  => countries[rand(countries.size)].id,
      :location    => Faker::Lorem.words(2).join(' ').titleize,
      :starts_on   => Date.today + rand(12),
      :ends_on     => Date.today + 12 + rand(5)
    }
    event = Event.create defaults.merge(options)
    event.approve! if rand(4) >= 1
  end

  def create_headline(options={})
    defaults = {
      :title        => Faker::Lorem.words(4).join(' ').titleize,
      :description  => simple_format(Faker::Lorem.paragraphs(4).join("\n")),
      :country_id   => countries[rand(countries.size)].id,
      :location     => Faker::Lorem.words(2).join(' ').titleize,
      :published_on => Date.today - rand(12),
      :approval     => rand(4) >= 1 ? 'approved' : 'pending'
    }
    headline = Headline.create defaults.merge(options)
  end
  
  task :load => :environment do
    require 'faker'
  end
  
  desc 'Populate the events table with a bunch of random events'
  task :populate_events => :load do
    5.times do
      today = Date.today
      starts_on = Time.mktime(today.year, today.month, rand(22)+1).to_date + rand(25)
      ends_on   = starts_on + rand(4)
      create_event :starts_on => starts_on, :ends_on => ends_on
    end
    25.times do
      starts_on = ((Date.today >> rand(12)) + rand(25))
      ends_on   = starts_on + rand(4)
      create_event :starts_on => starts_on, :ends_on => ends_on
    end
  end
  
  desc 'Remove all events'
  task :remove_events => :environment do
    Event.delete_all
  end
  
  desc 'Populate the headlines table with a bunch of random headlines'
  task :populate_headlines => :load do
    5.times do
      create_headline :published_on => Date.today
    end
    25.times do
      future = ((Date.today << rand(12)) + rand(25))
      create_headline :published_on => future
    end
  end
  
  desc 'Remove all news headlines'
  task :remove_headlines => :environment do
    Headline.delete_all
  end
  
  desc 'Clear news and events, populate with fake new data'
  task :populate => [:remove_events, :populate_events, :remove_headlines, :populate_headlines] do
    puts "Done!"
  end
end
