module AnsiSqlHelper
  # Creates an ANSI-SQL standard replacement for MySQL FIELDS()

  def self.fields_as_case(column, ordered_fields, max_value)
    return if ordered_fields.empty?
    order = *'CASE'
    ordered_fields.each do |p|
      v = p.is_a?(String) ? ActiveRecord::Base.sanitize(p) : p
      order << "WHEN #{column} = #{ActiveRecord::Base.sanitize(v)} THEN #{v}"
    end
    order << "ELSE '#{max_value}' END"
    order.join(' ')
  end

end
