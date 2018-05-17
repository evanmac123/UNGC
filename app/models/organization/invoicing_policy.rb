class Organization::InvoicingPolicy
  attr_reader :organization

  LEGACY_INVOICING_CUTOFF = Date.new(2018, 11, 30)

  def initialize(organization, revenue, now: -> { Date.current })
    @organization = organization
    @revenue = revenue
    @today = now.call()
  end

  def options
    options = [
      ["Invoice me now", @today],
    ]

    if before_cutoff_date
      options << ["Invoice me on:", LEGACY_INVOICING_CUTOFF]
    end

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
    when invoice_date < @today
      record.errors.add :invoice_date, "can't be in the past"
    when invoice_date > 1.year.from_now
      record.errors.add :invoice_date, "can't be more than a year from now"
    when invoice_date > @today && invoice_date < LEGACY_INVOICING_CUTOFF
      record.errors.add :invoice_date, "must be after #{LEGACY_INVOICING_CUTOFF}"
    end

    record.errors.empty?
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
        threshold_in_dollars: THRESHOLD.dollars.to_i,
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

  def before_cutoff_date
    @today < LEGACY_INVOICING_CUTOFF
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
