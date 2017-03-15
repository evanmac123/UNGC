class MoneyType < Virtus::Attribute
  def coerce(value)
    Monetize.parse(value)
  end
end
