require 'fastercsv'

class HabtmImporter
  
  FILES = [:case_stories_countries, :communication_on_progresses_languages, :communication_on_progresses_countries]
  
  CONFIG = {
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    :case_stories_countries => {:file   => 'R10_XREF_R07_TR01.txt',
                                :models => [Country, CaseStory]},
    :communication_on_progresses_languages => {:file   => 'R13_XREF_R02_TR10.txt',
                                               :models => [Language, CommunicationOnProgress]},
    :communication_on_progresses_countries => {:file   => 'R14_XREF_R02_TR01.txt',
                                               :models => [Country, CommunicationOnProgress]}
  }
  
  # Imports all the data in files located in options[:folder]
  def run(options={})
    setup(options)
    @files.each{|entry| import(entry, CONFIG[entry])}
  end

  # Imports the data from a single file
  def import(name, options)
    puts "Importing #{name}.."
    file = File.join(@data_folder, options[:file])
    # read the file
    FasterCSV.foreach(file, :col_sep => "\t",
                            :headers => :first_row) do |row|
      # create an object of the correct type and save
      o = find_model_object(options[:models].first, row[0])
      if o
        # found the first object, let's add the second
        m = find_model_object(options[:models].second, row[1])
        if m
          o.send(options[:models].last.class_name.tableize) << m
        else
          puts "** Could not find #{options[:models].second}: #{row[1]}"
        end
      else
        puts "** Could not find #{options[:models].first}: #{row[0]}"
      end
    end
  end
  
  def delete_all(options={})
    setup(options)
    @files.each{|entry| ActiveRecord::Base.connection.delete "DELETE FROM #{entry}"}
  end

  def delete_all_and_run(options={})
    delete_all(options)
    run(options)
  end

  private
    def setup(options)
      @data_folder = options[:folder] || File.join(RAILS_ROOT, 'lib/un7 tables')
      if options[:files]
        @files = options[:files].is_a?(Array) ? options[:files] : [options[:files]]
      else
        @files = FILES
      end
    end
    
    def find_model_object(model, id)
      if [CaseStory, CommunicationOnProgress].include? model
        model.find_by_identifier(id)
      elsif model == Country
        Country.find_by_code(id)
      elsif model == Language
        Language.find_by_old_id(id)
      end
    end
end