# frozen_string_literal: true

module Academy
  LAUNCH_DATE = Time.zone.parse("2018-09-12 04:00:00").freeze

  def self.table_name_prefix
    "academy_"
  end
end
