class Organization::InvoicingPolicy
  attr_reader :organization

  THRESHOLD = Money.from_amount(1_000_000_000)

  def initialize(organization, revenue, now: -> { Time.zone.now.to_date })
    @organization = organization
    @revenue = revenue
    @today = now.call()
    @cop_due_on = organization.try!(:cop_due_on)
    @include_cop_due_date = @cop_due_on.present?
  end

  def options
    return [] unless invoicing_required?

    jan1 = next_date month: 1, day: 1
    april1 = next_date month: 4, day: 1

    options = [
      ["Invoice me now", @today],
      ["Invoice me on 1 January #{jan1.year}", jan1],
      ["Invoice me on 1 April #{april1.year}", april1],
    ]

    if @include_cop_due_date && @cop_due_on >= @today
      options << [
        I18n.t("level_of_participation.invoice_on_next_cop_due_date", cop_due_on: @cop_due_on),
        @cop_due_on
      ]
    end

    options << ["Invoice me on:", nil]

    options
  end

  def invoicing_required?
    ln = @organization.try!(:country).try!(:local_network)

    case
    when ln.nil?, ln.business_model.nil?
      true
    when ln.revenue_sharing?
      ln.gco? || ln.invoice_options_available == "yes"
    when ln.global_local?
      rev = @revenue || Money.from_amount(0)
      rev >= THRESHOLD || ln.invoice_options_available == "yes"
    when ln.not_yet_decided?
      ln.invoice_options_available == "yes"
    end
  end

  def validate(record)
    return unless invoicing_required?

    invoice_date = record.invoice_date
    case
    when invoice_date.blank?
      record.errors.add :invoice_date, "can't be blank"
    when invoice_date < Time.zone.now.to_date
      record.errors.add :invoice_date, "can't be in the past"
    when invoice_date > 1.year.from_now
      record.errors.add :invoice_date, "can't be more than a year from now"
    end
  end

  private

  def next_date(month:, day:)
    today = Time.zone.now.to_date
    this_year = Date.new(today.year, month, day)
    if this_year >= today
      this_year
    else
      this_year + 1.year
    end
  end

end
