class String
  def blank?
    # old: self !~ /\S/ as of Rails 2.3.3
    # This fails if the string contains invalidly coded characters, which our
    # data sometimes does - this version takes valid_encoding into account
    if (!self.respond_to?(:valid_encoding?) or self.valid_encoding?)
      self !~ /\S/
    else
      self.strip.size == 0
    end
  end
end

class Array
  def sixth
    self[5]
  end
end
