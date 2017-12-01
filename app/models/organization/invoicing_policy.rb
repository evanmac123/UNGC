class Organization::InvoicingPolicy
  attr_reader :organization

  def initialize(organization, revenue, now: -> { Time.zone.now.to_date })
    @organization = organization
    @revenue = revenue
    @today = now.call()
    @cop_due_on = organization&.cop_due_on
    @include_cop_due_date = @cop_due_on.present?
  end

  def options
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

  def validate(record)
    return unless invoicing_required?

    invoice_date = record.invoice_date
    case
    when invoice_date.blank?
      record.errors.add :invoice_date, "can't be blank"
    when !invoice_date.is_a?(Date)
      record.errors.add :invoice_date, "must be a valid date"
    when invoice_date < Time.zone.now.to_date
      record.errors.add :invoice_date, "can't be in the past"
    when invoice_date > 1.year.from_now
      record.errors.add :invoice_date, "can't be more than a year from now"
    end
  end

  def to_h
    invoicing_strategy.to_h
  end

  def invoicing_required?
    invoicing_strategy.invoicing_required?
  end

  class DefaultStrategy
    def invoicing_required?
      true
    end

    def to_h
      {type: :default, value: invoicing_required?}
    end
  end

  class RevenueSharing
    def initialize(local_network)
      @local_network = local_network
    end

    def invoicing_required?
      @local_network.gco? || @local_network.invoice_options_available == "yes"
    end

    def to_h
      {
        type: @local_network.business_model,
        value: invoicing_required?
      }
    end
  end

  class GlobalLocal
    THRESHOLD = Money.from_amount(1_000_000_000).freeze

    def initialize(local_network, revenue)
      @local_network = local_network
      @revenue = revenue || Money.from_amount(0)
    end

    def invoicing_required?
      (@revenue >= THRESHOLD) || @local_network.invoice_options_available == "yes"
    end

    def to_h
      {
        type: @local_network.business_model,
        threshold_in_cents: THRESHOLD.cents,
        local: @local_network.invoice_options_available == "yes",
        global: true,
      }
    end
  end

  class NotYetDecided
    def initialize(local_network)
      @local_network = local_network
    end

    def invoicing_required?
      false
    end

    def to_h
      {
        type: @local_network.business_model,
        value: invoicing_required?
      }
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

  def invoicing_strategy
    ln = @organization&.local_network

    case
    when ln.nil?, ln.business_model.nil?
      DefaultStrategy.new
    when ln.revenue_sharing?
      RevenueSharing.new(ln)
    when ln.global_local?
      GlobalLocal.new(ln, @revenue)
    when ln.not_yet_decided?
      NotYetDecided.new(ln)
    end
  end

end
