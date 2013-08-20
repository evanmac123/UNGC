class InvoiceReminder
  def initialize
    @logger = Logger.new(File.join(Rails.root, 'log', 'invoice_reminder.log'))
  end

  def deliver_all
    @organizations = Organization.companies_and_smes.ready_for_invoice

    @organizations.each do |organization|
      begin
        log "Emailing organization #{organization.id}:#{organization.name}"
        invoice_mailer_for(organization).deliver
      rescue
        log :error, "Could not send email: #{$!}"
      end
    end
  end

  private
    def invoice_mailer_for(organization)
      if organization.pledge_amount.to_i > 0
        OrganizationMailer.foundation_invoice(organization)
      else
        OrganizationMailer.foundation_reminder(organization)
      end
    end

    def log (method="info", string)
      @logger.send method.to_sym, "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} : #{string}"
    end
end
