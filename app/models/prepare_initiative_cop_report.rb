class PrepareInitiativeCopReport
  include ActiveModel::Model

  attr_accessor(
    :initiative_name,
    :start_year,
    :start_month,
    :start_day,
    :end_year,
    :end_month,
    :end_day,
  )

  validates :initiative_name, presence: true
  validate :has_date_range?
  validate :end_date_is_larger?

  def date_range
    start_date..end_date
  end

  # TODO unit test bad values like deb 29 on a non-leap year, or day 2012
  # or values that don't convert to_i
  def start_date
    Date.new(start_year.to_i, start_month.to_i, start_day.to_i)
  rescue ArgumentError
    1.day.ago
  end

  def end_date
    Date.new(end_year.to_i, end_month.to_i, end_day.to_i)
  rescue ArgumentError
    Date.today
  end

  private

  def has_date_range?
    unless start_date && end_date
      self.errors.add :base, "Must have valid start and end dates"
    end
  end

  def end_date_is_larger?
    unless end_date > start_date
      self.errors.add :base, "Start date must come before end date"
    end
  end

end
