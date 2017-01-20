class PrepareInitiativeCopReport
  include ActiveModel::Model

  attr_accessor :start_date, :end_date

  validates :start_date, presence: true
  validates :end_date, presence: true

  def valid?
    has_date_range && end_date_is_larger
  end

  def display_download_link
  end

  def date_range
    query_start_date..query_end_date
  end

  private

  def has_date_range
    query_start_date && query_end_date
  end

  def end_date_is_larger
    query_end_date > query_start_date
  end

  def query_start_date
    Date.new(start_year, start_month, start_day)
  end

  def query_end_date
    Date.new(end_year, end_month, end_day)
  end

  def start_year
    value = start_date.fetch(:start_year)
    value.to_i
  end
  #
  def start_month
    value = start_date.fetch(:start_month)
    value.to_i
  end
  #
  def start_day
    value = start_date.fetch(:start_day)
    value.to_i
  end
  #
  def end_year
    value = end_date.fetch(:end_year)
    value.to_i
  end
  #
  def end_month
    value = end_date.fetch(:end_month)
    value.to_i
  end
  #
  def end_day
    value = end_date.fetch(:end_day)
    value.to_i
  end


end
