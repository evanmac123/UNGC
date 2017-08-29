class DataVisualization::CountryCopQueries
    attr_reader :data

    def initialize(country_id)
      @data = CommunicationOnProgress
        .joins(:organization)
        .where(organizations: {country_id: country_id})
        .where("cop_type is null or cop_type not in ('grace', 'reporting_cycle_adjustment', 'non_business')")
        .where("format is null or format not in ('grace_letter', 'reporting_cycle_adjustment')")

      @country_name = Country.find(country_id).name
    end

    def cop_count
      data.count
    end

    def cop_type_count
      results = data.group(:cop_type).count
      results.map do |cop_type, count|
        { cop_type: cop_type, count: count, country: @country_name }
      end
    end

    def differentiation_count
      results = data.group(:differentiation).count

      results.map do |differentiation, count|
        { differentiation: differentiation,
          count: count,
          country: @country_name
        }
      end
    end

    def cop_count_by_year
      results = data.group("year(communication_on_progresses.created_at)").count
      results.map do |year, count|
        { year: year, count: count, country: @country_name }
      end
    end

    def cop_count_by_month_in_year
      results = data.group("month(communication_on_progresses.created_at)",
                 "year(communication_on_progresses.created_at)").count

      results.map do |(month, year), count|
          { month: month, year: year, count: count, country: @country_name}
      end
    end

    def cop_type_count_by_year
      results = data.group(:cop_type, "year(communication_on_progresses.created_at)").count
      results.map do |year, cop_type, count|
        { year: year, cop_type: cop_type, count: count, country: @country_name }
      end
    end

    def differentation_count_by_year
      results = data.group(:differentiation, "year(communication_on_progresses.created_at)").count

      results.map do |(differentiation, year), count|
        { differentiation: differentiation, year: year, count: count, country: @country_name }
      end
    end

    def cop_type_by_month_in_year
      results = data.group(:cop_type, "month(communication_on_progresses.created_at)",
                 "year(communication_on_progresses.created_at)").count

     results.map do |(month, year), cop_type, count|
       { month: month, year: year, cop_type: cop_type, count: count, country: @country_name }
     end
    end

    def differentation_by_month_in_year
      results = data.group(:differentation, "month(communication_on_progresses.created_at)",
                 "year(communication_on_progresses.created_at)").count

      results.map do |(month, year), differentation, count|
        { month: month, year: year, differentation: differentation, count: count, country: @country_name }
      end
    end


    def cop_type_by_organization_size
      results = data.group(:organization_id, ('cop_type'))
      .pluck('organizations.employees, COUNT(communication_on_progresses.id) as communication_on_progresses_count', 'communication_on_progresses.cop_type')

      results.map do |cop_type, size, count|
        { cop_type: cop_type, size: size, count: count, country: @country_name }
      end
    end

    def differentiation_by_organization_size
      results = data.group(:organization_id, ('differentiation'))
      .pluck('organizations.employees, COUNT(communication_on_progresses.id) as communication_on_progresses_count', 'communication_on_progresses.differentiation', 'year(communication_on_progresses.created_at)')

      results.map do |size, count, differentiation, year|
        {  size: size, count: count, differentiation: differentiation, year: year, country: @country_name }
      end
    end

end
