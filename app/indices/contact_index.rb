ThinkingSphinx::Index.define :contact, :with => :active_record do
  indexes first_name
  indexes last_name
  indexes middle_name
  indexes email

  set_property :enable_star => true
  set_property :min_prefix_len => 4
end
