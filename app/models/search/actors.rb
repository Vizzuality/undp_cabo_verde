class Search::Actors
  attr_reader :page, :per_page

  def initialize(options)
    @id = 1
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).
      offset(@per_page * (@page-1)).all
  end

  def total_cnt
    @query.size
  end

  private

    def initialize_params(options)
      @options = Search::ActorsParams.sanitize(options)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end

    # Table name LOCATIONS
    # Model name Localizations
    def initialize_query
      @query = Actor.all

      @query = @query.where(type: @levels) if @levels

      if @domains.present?
        @query = @query.joins(:categories).where({ categories: { id: @domains }})
      end

      if @search_term.present?
        @query = @query.where("actors.name ILIKE ? OR actors.short_name ILIKE ? OR actors.observation ILIKE ?", "%#{@search_term}%", "%#{@search_term}%", "%#{@search_term}%")
      end

      if @start_date || @end_date
        @first_date  = (Time.zone.now - 50.years).beginning_of_day
        @second_date = (Time.zone.now + 50.years).end_of_day
      end

      if @start_date && !@end_date
        where_query = "COALESCE(locations.start_date, '#{@first_date}') >= ? OR
                       COALESCE(locations.end_date, '#{@second_date}') >= ?",
                       @start_date.to_time.beginning_of_day, @start_date.to_time.beginning_of_day

        a = @query.joins(:location).where(where_query)

        b = @query.joins(:localizations).where(where_query)

        sql = @query.connection.unprepared_statement {
          "((#{a.to_sql}) UNION (#{b.to_sql})) AS actors"
        }

        @query = Actor.from(sql)
      end

      if @end_date && !@start_date
        where_query = "COALESCE(locations.end_date, '#{@second_date}') <= ? OR
                       COALESCE(locations.start_date, '#{@first_date}') <= ?",
                       @end_date.to_time.end_of_day, @end_date.to_time.beginning_of_day

        a = @query.joins(:location).where(where_query)

        b = @query.joins(:localizations).where(where_query)

        sql = @query.connection.unprepared_statement {
          "((#{a.to_sql}) UNION (#{b.to_sql})) AS actors"
        }

        @query = Actor.from(sql)
      end

      if @start_date && @end_date
        where_query = "COALESCE(locations.start_date, '#{@first_date}') BETWEEN ? AND ? OR
                       COALESCE(locations.end_date, '#{@second_date}') BETWEEN ? AND ? AND
                       ? BETWEEN COALESCE(locations.start_date, '#{@first_date}') AND COALESCE(locations.end_date, '#{@second_date}')",
                       @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                       @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                       @start_date.to_time.beginning_of_day

        a = @query.joins(:location).where(where_query)

        b = @query.joins(:localizations).where(where_query)

        sql = @query.connection.unprepared_statement {
          "((#{a.to_sql}) UNION (#{b.to_sql})) AS actors"
        }

        @query = Actor.from(sql)
      end

      @query = @query.distinct
    end
end
