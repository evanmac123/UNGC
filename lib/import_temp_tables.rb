require 'csv'

def datetime_to_date(dtime)
  if dtime =~ /\d{4}-\d{2}-\d{2} .*/
    year, month, day = dtime.split(' ').first.split('-')
    "#{year}-#{month}-#{day}"
  end
end

class ImportTempTables

  def run
    @data_folder = File.join(Rails.root, 'lib/un7_tables')
    file = File.join(@data_folder, "R01_ORGANIZATION_TEMP.csv")

    CSV.foreach(file, :headers => :first_row) do |row|
      o = Organization.new
      o.old_tmp_id = row["ID"]
      o.name = row["ORG_NAME"]
      o.employees = row["ORG_NB_EMPLOY"]
      o.pledge_amount = row["PLEDGE_AMOUNT"]
      o.added_on = datetime_to_date(row["ORG_DATE_CREATE"])
      o.url = row["ORG_URL"]
      o.last_modified_by_id = Contact.find_by_old_id(row["R10_CONTACT_ID"]).try(:id) if row["R10_CONTACT_ID"]
      o.reviewer_id = Contact.find_by_old_id(row["R10_CONTACT_ID"]).try(:id) if row["R10_CONTACT_ID"]
      o.organization_type_id = OrganizationType.find_by_name(row["TR02_TYPE"]).try(:id)
      o.sector_id = Sector.find_by_old_id(row["SECTOR_ID"]).try(:id)
      o.country_id = Country.find_by_code(row["TR01_COUNTRY_ID"]).try(:id)
      o.participant = false
      o.active = false

      # publically listed, ticker and exchange
      o.listing_status_id = ListingStatus.find_by_old_id(row["ORG_LISTED_STATUS"]).try(:id) if row["ORG_LISTED_STATUS"]
      o.stock_symbol = row["ORG_LIST_CODE"]
      o.exchange_id = Exchange.find_by_code(row["ORG_LIST_EXCHANGE_CODE"]).try(:id) if row["ORG_LIST_EXCHANGE_CODE"]
      o.is_ft_500 = row["ORG_ISGLOBAL500"]

      # get current review status
      review_state = row["ORG_STATUS"]

      case review_state.to_i
        when 0
          o.state = 'rejected'
          o.rejected_on = datetime_to_date(row["ORG_DATE_REJECT"])
        when 1
          # organizations that have been modified are considered to be in review
          if o.last_modified_by_id.to_i > 0
            o.state = 'in_review'
          else
            o.state = 'pending_review'
          end
          o.modified_on = datetime_to_date(row["ORG_DATE_CREATE"])
        when 2
          o.state = 'network_review'
          o.network_review_on = datetime_to_date(row["ORG_DATE_APPROVE"])
      end

      # Approved organizations have already been imported
      unless review_state.to_i == 3
        o.save
        # puts "#{o.id}: #{o.name} is #{o.state}"
      end

    end

    file = File.join(@data_folder, "R10_CONTACTS_TEMP.csv")
    CSV.foreach(file, :headers => :first_row) do |row|
      c = Contact.new
      c.prefix = row["CONTACT_PREFIX"]
      c.first_name = row["CONTACT_FNAME"]
      c.middle_name = row["CONTACT_MNAME"]
      c.last_name = row["CONTACT_LNAME"]
      c.job_title = row["CONTACT_JOB_TITLE"]
      c.email = row["CONTACT_EMAIL"]
      c.phone = row["CONTACT_PHONE"]
      c.fax = row["CONTACT_FAX"]
      c.organization_id = Organization.find_by_old_tmp_id(row["ORG_ID"].to_i).try(:id)
      c.address = row["CONTACT_ADDRESS"]
      c.address_more = row["CONTACT_ADDRESS2"]
      c.city = row["CONTACT_CITY"]
      c.state = row["CONTACT_STATE"]
      c.postal_code = row["CONTACT_CODE_POSTAL"]
      c.country_id = Country.find_by_code(row["CONTACT_COUNTRY_ID"]).try(:id)

      # assign contact roles
      role = Role.find_by_old_id row["ROLE_ID"]
      c.roles << role if role

      # generate login and password for Contact Point
      if row["ROLE_ID"].to_i == 4
        c.login = "#{row["ID"]}ungc"
        c.password = "ungc#{row["ID"]}"
      end

      # don't add if organization has been approved and is now an active participant
      if contact_organization = Organization.find_by_old_tmp_id(row["ORG_ID"])
        unless contact_organization.state == 'approved' and contact_organization.participant and contact_organization.active
          c.save
          # puts "Saved #{c.id} for #{contact_organization.name}"
        end
      end

    end

  end
end
