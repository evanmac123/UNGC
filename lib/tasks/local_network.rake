namespace :local_network do

  desc "import local network business models from csv"
  task import_business_models: :environment do
    models = Set.new
    managed_by = Set.new
    options = Set.new
    currencies = Set.new
    problems = []

    country_column = 1
    business_model_column = 21
    invoice_managed_by_column = 22
    invoice_options_available_column = 23
    invoicing_curreny_column = 24

    line = 0
    CSV.foreach("lib/tasks/local_network/ln-data.csv") do |row|
      line += 1
      next if line < 3

      # 1h9fA97l_wWi-fVTIWKSjP1YiobaVScSCxx-jhtL8MxM,Denmark,Revenue Sharing,Link,Europe,Ole,Emerging,
      # 11OhilYKijXsDAzWFBWcWturpEvXDFK5w16nn4iOHwNo,Finland,Not yet decided,Link,Europe,Ole,Emerging,

      fixes = {
        # "Denmark" => "Nordic Counties",
        # "Finland" => "Nordic Counties",
        "Macedonia, The Former Yugoslav Republic of" => "Macedonia, The FYR",
        "Russian Federation" => "Russia",
        "United Kingdom" => "UK",
        "United States of America" => "USA",
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

        params[:business_model] = case business_model
                                  when "Not yet decided" then "not_yet_decided"
                                  when "Revenue Sharing" then "revenue_sharing"
                                  when "Global Local" then "global_local"
                                  when "#REF!", nil then nil
                                  else raise "Unexpected business model #{business_model}"
                                  end

        params[:invoice_managed_by] = case invoice_managed_by
                                      when "GCO" then "gco"
                                      when "Local Network" then "local_network"
                                      when "N/A (global-local)", "#REF!", nil then nil
                                      else raise "Unexpected business model #{business_model}"
                                      end

        params[:invoice_options_available] = case invoice_options_available
                                             when "Yes" then "yes"
                                             when "No" then "no"
                                             when "N/A (global-local)", "#REF!", nil then nil
                                             else raise "Unexpected business model #{business_model}"
                                             end

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

end
