namespace :local_network do

  desc "import local network business models from csv"
  task import_business_models: :environment do
    models = Set.new
    managed_by = Set.new
    options = Set.new
    currencies = Set.new
    problems = []

    country_column = 1
    business_model_column = 13
    invoice_managed_by_column = 14
    invoice_options_available_column = 15
    invoicing_curreny_column = 16

    line = 0
    CSV.foreach("lib/tasks/local_network/ln-data.csv") do |row|
      line += 1
      next if line < 2

      fixes = {
        # "Denmark" => "Nordic Counties",
        # "Finland" => "Nordic Counties",
        "Macedonia, The Former Yugoslav Republic of" => "Macedonia, The FYR",
        "Russian Federation" => "Russia",
        "Belguim" => "Belgium",
        "Democratc Republic of Congo" => "Congo, Democratic Republic of",
        "UAE" => "United Arab Emirates",
        "United Kingdom" => "UK",
        "United States of America" => "USA",
        "United States" => "USA",
      }

      country = row[country_column]
      ln_name = fixes.fetch(country, country)
      business_model = row[business_model_column]
      invoice_managed_by = row[invoice_managed_by_column]
      invoice_options_available = row[invoice_options_available_column]
      invoice_currency = row[invoicing_curreny_column]

      managed_by << invoice_managed_by
      options << invoice_options_available
      currencies << invoice_currency

      models << business_model
      local_network = LocalNetwork.find_by(name: ln_name)
      if local_network.present?
        params = {}

        mod = case business_model
              when "Not yet decided" then "not_yet_decided"
              when "Revenue Sharing" then "revenue_sharing"
              when "Global Local" then "global_local"
              when nil then nil
              else raise "Unexpected business model #{business_model}"
              end
        params[:business_model] = mod

        mgb = case invoice_managed_by
              when "GCO" then "gco"
              when "Local Network" then "local_network"
              when "Global-Local" then "global_or_local"
              when "Not yet decided" then "on_hold"
              when nil then nil
              else raise "Unexpected value for invoice_managed_by: #{invoice_managed_by}"
              end
        params[:invoice_managed_by] = mgb

        opt = case invoice_options_available
              when "Yes" then "yes"
              when "No" then "no"
              when nil then nil
              else raise "Unexpected value for invoice_options_available: #{invoice_options_available}"
              end
        params[:invoice_options_available] = opt

        params[:invoice_currency] = invoice_currency unless invoice_currency == "#REF!"

        local_network.update!(params)
      else
        problems << country
      end
    end

    ap business_model: models
    ap invoice_managed_by: managed_by
    ap invoice_options_available: options

    ap problems: problems
  end

  task migrate_network_representatives: :environment do
    ActiveRecord::Base.transaction do
      r = Role.find_by(name: 'Network Representative')
      representatives = Contact.for_roles(r)
      representatives.each do |c|
        c.roles.destroy(r)
        c.roles.create(id: Role.general_contact.id)
      end
    end
  end
end
