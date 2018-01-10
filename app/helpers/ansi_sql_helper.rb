module AnsiSqlHelper
  # Creates an ANSI-SQL standard replacement for MySQL FIELDS()

  def self.fields_as_case(column, ordered_fields)
    return if ordered_fields.empty?
    order = *'CASE'
    ordered_fields.each_with_index do |p, idx|
      v = p.is_a?(String) ? ActiveRecord::Base.sanitize(p) : p
      order << "WHEN #{column} = #{v} THEN #{idx}"
    end
    order << "ELSE #{ordered_fields.length} END"
    order.join(' ')
  end

end
