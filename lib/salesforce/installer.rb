class SalesforceInstaller
  attr_reader :client_id,
              :client_secret,
              :password,
              :token,
              :host,
              :username,
              :callback_url

  module Remote
  end

  # TODO it would be better to be able to update the trigger and class
  # definitions rather than deleting and recreating them. Figure out how
  # and then do that.

  def initialize(options)
    @client_id = options.fetch(:client_id)
    @client_secret = options.fetch(:client_secret)
    @password = options.fetch(:password)
    @token = options.fetch(:token)
    @host = options.fetch(:host)
    @username = options.fetch(:username)
    @callback_url = options.fetch(:callback_url)

    authenticate
    client.sobject_module = Remote
    client.materialize([
      "Account",
      "Campaign",
      "Opportunity",
      "ApexClass",
      "ApexTrigger",
      "UNGCSync__c"
    ])
  end

  def show_sync_queue
    Remote::UNGCSync__c.all
  end

  def clear_sync_queue
    Remote::UNGCSync__c.all.each do |job|
      job.delete
    end
  end

  def create_triggers
    Dir.glob('lib/salesforce/triggers/*.apex')
      .map { |path| Pathname.new(path) }.each do |path|

      name = path.basename.sub_ext('').to_s.camelize
      table = name.match(/^Handle(.+)(Insert|Delete|Undelete|Update)$/)[1]
      body = File.read(path)

      create_trigger(name, table, body)
    end
  end

  def create_classes
    [
      "UngcJsonSerializer",
      "UngcCampaignSerializer",
      "UngcOpportunitySerializer",
      "UngcPendingJob",
      "UngcJob",
      "UngcSyncRequest",
      "UngcCampaignDelete",
      "UngcCampaignUndelete",
      "UngcCampaignUpsert",
      "UngcOpportunityDelete",
      "UngcOpportunityUndelete",
      "UngcOpportunityUpsert",
      "UngcPendingCampaignJobs",
      "UngcPendingOpportunityJobs",
      "UngcPendingJobs",
      "UngcSync",
    ].each do |file|
      path = Pathname.new("lib/salesforce/classes/#{file}.apex")
      name = path.basename.sub_ext('').to_s.camelize
      body = File.read(path)
      body.gsub! '{{CALLBACK_URL}}', callback_url # HACK override the URL
      create_class(name, body)
    end
  end

  private

  def create_trigger(name, table, body)
    puts "Recreating trigger #{name} on #{table}"
    t = Remote::ApexTrigger.query("Name = '#{name}'").first
    if t.present?
      print "\tTrigger exists. Deleting..."
      t.delete
      puts "done."
    end

    print "\tCreating trigger..."
    Remote::ApexTrigger.create("Name" => name, "TableEnumOrId" => table, "Body" => body)
    puts "done."
  end

  def create_class(name, body)
    puts "Recreating class #{name}"
    klass = Remote::ApexClass.find_by_Name(name)
    if klass.present?
      print "\tClass exists. Deleting..."
      klass.delete
      puts "done."
    end

    print "\tCreating class..."
    klass = Remote::ApexClass.create("Name" => name, "Body" => body)
    puts "done"
  end

  def authenticate
    client.authenticate username: username, password: token_and_password
  end

  def token_and_password
    "#{password}#{token}"
  end

  def client
    @client ||= Databasedotcom::Client.new(
      host: host,
      client_id: client_id,
      client_secret: client_secret
    )
  end

end
