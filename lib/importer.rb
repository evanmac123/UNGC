require 'csv'

class Importer
  include ImporterHooks
  include ImporterMapping
  
  # Imports all the data in files located in options[:folder]
  def run(options={})
    setup(options)
    @files.each{|entry| import(entry, CONFIG[entry])}
    HabtmImporter.new.delete_all_and_run(options) if @run_habtm
  end

  # Imports the data from a single file
  def import(name, options)
    log "Importing #{name}.."
    raise "Unable to find '#{name}' in importer options." unless options
    file = File.join(@data_folder, options[:file])
    model = name.to_s.camelize.constantize
    # read the file
    CSV.foreach(file, :headers => :first_row) do |row|
      # create an object of the correct type and save
      o = model.new
      options[:fields].each_with_index do |field,i|
        next if field.nil?
        # fields that end with _id require a lookup
        if field == :country_id
          found = Country.find_by_code(row[i])
          o.country_id = found.id if found
        elsif field == :parent_id
          if name == :sector
            # sector tree depends on the icb_number field
            o.parent_id = Sector.find_by_icb_number(row[i]).try(:id) if row[i]
          else
            o.parent_id = model.find_by_old_id(row[i]).id if row[i]
          end
        elsif field == :sector_id
          o.sector_id = Sector.find_by_old_id(row[i]).id if row[i]
        elsif field == :exchange_id
          o.exchange_id = Exchange.find_by_code(row[i]).try(:id) if row[i]
        elsif field == :listing_status_id
          o.listing_status_id = ListingStatus.find_by_old_id(row[i]).try(:id) if row[i]
        elsif field == :publication_id
          o.publication_id = LogoPublication.find_by_old_id(row[i]).id if row[i]
        elsif field == :cop_score_id
          o.cop_score_id = CopScore.find_by_old_id(row[i]).id if row[i]
        elsif field == :logo_request_id
          o.logo_request_id = LogoRequest.find_by_old_id(row[i]).try(:id) if row[i]
        elsif field == :logo_file_id
          o.logo_file_id = LogoFile.find_by_old_id(row[i]).id if row[i]
        elsif field == :removal_reason_id
          o.removal_reason_id = RemovalReason.find_by_old_id(row[i]).try(:id) if row[i]
        elsif field == :organization_id
          if [:contact, :communication_on_progress, :case_story].include? name
            # some tables are linked to organization by name
            o.organization_id = Organization.find_by_name(row[i].strip).try(:id) if row[i]
          else
            o.organization_id = Organization.find_by_old_id(row[i]).try(:id) if row[i]
          end
        elsif field == :initiative_id and lookup = row[i]
          o.initiative = Initiative.find_by_old_id(lookup)
        elsif [:contact_id, :reviewer_id, :last_modified_by_id].include? field
          o.send("#{field}=", Contact.find_by_old_id(row[i]).try(:id)) if row[i]
        elsif field == :organization_type_id
          o.organization_type_id = OrganizationType.find_by_name(row[i]).try(:id) if row[i]
        elsif field == :category
          # CaseStory.CATEGORY becomes two fields - is_partnership_project and is_internalization_project
          o.is_partnership_project = [1, 3].include?(row[i].to_i)
          o.is_internalization_project = [2, 3].include?(row[i].to_i)
        elsif [:added_on, :modified_on, :joined_on, :delisted_on, :one_year_member_on, :inactive_on, :cop_due_on].include?(field) and lookup = row[i]
          if lookup =~ /\d{4}-\d{2}-\d{2} .*/
            year, month, day = lookup.split(' ').first.split('-')
          else
            month, day, year = lookup.split('/')
          end
          begin
            o.send("#{field}=", Time.mktime(year, month, day).to_date)
          rescue
            log "** [minor error] Could not set #{row[i]} as #{field}"
          end
        else
          value = row[i]
          unless value.blank?
            value = true if value.is_a?(String) && value.downcase == 'true'
            value = false if value.is_a?(String) && value.downcase == 'false'
            value.strip! if value.is_a?(String)
            o.send("#{field}=", value)
          end
        end
      end
      update_state(name, o)
      
      if perform_validation?(name)
        saved = o.save
        log "** [error] Could not save #{name}: #{row} - #{o.errors.full_messages.to_sentence} - #{o.inspect}" unless saved
      else
        begin
          o.save(false)
        rescue
          log "** [error] Could not save #{name}: #{row}"
        end
      end
    end
    log "-- [info] Imported #{model.count} records."
    # call a post_* method for work required after importing a file
    send("post_#{name}") if self.respond_to?("post_#{name}")
  end
  
  def delete_all(options={})
    setup(options)
    @files.each{|entry| entry.to_s.camelize.constantize.delete_all}
  end

  def delete_all_and_run(options={})
    delete_all(options)
    run(options)
  end

  # Creates some instance variables used throughout the application
  # :data_file - folder where the .CVS files are located, default is lib/un7_tables
  # :silent - avoid output statements if true
  # :files - indicates what files you want to import, defaults to all
  # :habtm - runs the HabtmImporter after Importer if set to true
  def setup(options={})
    @data_folder = options[:folder] || File.join(RAILS_ROOT, 'lib/un7_tables')
    @silent = options[:silent] || false
    if options[:files]
      @files = options[:files].is_a?(Array) ? options[:files] : [options[:files]]
    else
      @files = FILES
    end
    # run_habtm default is true if user wants to run the importer for all files
    @run_habtm = options[:run_habtm] || (@files == FILES)
    no_observers
  end

  private
    # translates the old database status into our state fields
    def update_state(name, model)
      case name
        when :logo_request then
          # (0: “Pending Review” 1: “In Review”, 2”:“Declined” or 3:“Accepted)
          model.state = ['pending_review', 'in_review', 'rejected', 'approved'][model.status.to_i]
        when :case_story then
          # Case Story Status. Values( -1: “Rejected”, 0:”In Review”, 1:”Accepted”
          model.state = ['rejected', 'in_review', 'approved'][model.status.to_i + 1]
        when :organization then
          # all organizations in R01_ORGANIZATION were approved
          model.state = 'approved'
          # COP state - 2=Active, 1=Non-communicating, 0=Inactive, 3=Delisted
          model.cop_state = ['delisted','noncommunicating','active','delisted'][model.cop_status.to_i]
          if model.participant == 1 && model.active == 0
            model.cop_state = 'delisted'
          end
        when :communication_on_progress then
          # COP Status (0: “In review”, 1: “Published”, -1: “Rejected”)
          model.state = ['rejected', 'in_review', 'approved'][model.status.to_i + 1]
      end
    end
    
    def perform_validation?(name)
      name != :logo_comment
    end
    
    def no_observers
      # We don't want observers to be called on import
      unless RAILS_ENV == 'test'
        # if we delete observers when running test, other tests fail
        Organization.delete_observers
        LogoComment.delete_observers
      end
    end
    
    def log(string)
      puts(string) unless @silent
    end
end