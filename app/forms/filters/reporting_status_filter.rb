class Filters::ReportingStatusFilter < Filters::FlatSearchFilter

  def initialize(selected)
    items = Organization.distinct
      .pluck(:cop_state)
      .map { |state| ReportingStatus.new(state) }

    super(items, selected)
    self.label = 'Status'
    self.key = 'reporting_status'
  end

  private

  ##
  # FilterOptions require id and name
  ReportingStatus = Struct.new(:status) do
    alias_method :id, :status
    alias_method :name, :status
  end

end
