module AnsiSqlHelper
  # Creates an ANSI-SQL standard replacement for MySQL FIELDS()

  def self.fields_as_case(column, ordered_fields, max_value)
    return if ordered_fields.empty?
    order = *'CASE'
    ordered_fields.each {|p| order << "WHEN #{column} = '#{p}' THEN '#{p}'"}
    order << "ELSE '#{max_value}' END"
    ActiveRecord::Base.sanitize(order.join(' '))
  end

end
