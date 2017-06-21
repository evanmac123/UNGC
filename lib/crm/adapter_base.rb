module Crm
  class AdapterBase
    def number(input, integer_precision = 18, fractional_precision = 0)
      # TODO: figure out what to do if the number exceeds the precision
      coerce(input)
    end

    def text(input, length = nil)
      if length
        coerce(input.try!(:truncate, length))
      else
        coerce(input)
      end
    end

    def phone(input)
      coerce(input.try!(:truncate, 40))
    end

    def fax(input)
      coerce(input.try!(:truncate, 40))
    end

    def picklist(input)
      coerce(Array.wrap(input).join(";"))
    end

    def email(input)
      coerce(input)
    end

    def postal_code(input)
      coerce(input.try!(:truncate, 20))
    end

    protected

    def coerce(input)
      Salesforce.coerce(input)
    end
  end
end
