require 'csv'

class HabtmImporter

  FILES = [:case_stories_countries, :case_stories_principles, :communication_on_progresses_languages,
            :communication_on_progresses_countries, :communication_on_progresses_principles, :logo_files_logo_requests]

  CONFIG = {
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    :case_stories_countries => {:file   => 'R10_XREF_R07_TR01.csv',
                                :models => [Country, CaseStory]},
    :case_stories_principles => {:file   => 'R09_XREF_R07_TR05.csv',
                                 :models => [CaseStory, Principle]},
    :communication_on_progresses_languages => {:file   => 'R13_XREF_R02_TR10.csv',
                                               :models => [Language, CommunicationOnProgress]},
    :communication_on_progresses_countries => {:file   => 'R14_XREF_R02_TR01.csv',
                                               :models => [Country, CommunicationOnProgress]},
    :communication_on_progresses_principles => {:file   => 'R15_XREF_R02_TR05.csv',
                                                :models => [CommunicationOnProgress, Principle]},
    :logo_files_logo_requests => {:file   => 'TR19_LOGO_APPROVALS.csv',
                                  :models => [LogoRequest, LogoFile],
                                  :index  => [1,2]}
  }

  # Imports all the data in files located in options[:folder]
  def run(options={})
    setup(options)
    @files.each{|entry| import(entry, CONFIG[entry])}
  end

  # Imports the data from a single file
  def import(name, options)
    log "Importing #{name}.."
    file = File.join(@data_folder, options[:file])
    # by default we use the first two fields from the feed
    index = options[:index] || [0, 1]
    # read the file
    CSV.foreach(file, :headers => :first_row) do |row|
      # create an object of the correct type and save
      o = find_model_object(options[:models].first, row[index.first])
      if o
        # found the first object, let's add the second
        m = find_model_object(options[:models].second, row[index.last])
        if m
          o.send(options[:models].last.class_name.tableize) << m
        else
          log "** [error] Could not find #{options[:models].second}: #{row[1]}"
        end
      else
        log "** [error] Could not find #{options[:models].first}: #{row[0]}"
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
      @data_folder = options[:folder] || File.join(Rails.root, 'lib/un7_tables')
      @silent = options[:silent] || false
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
      else
        model.find_by_old_id(id)
      end
    end

    def log(string)
      puts(string) unless @silent
    end
end
