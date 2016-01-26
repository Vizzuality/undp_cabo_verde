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
    @query.count
  end

  private

    def initialize_params(options)
      @options = Search::ActorsParams.sanitize(options)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end

    # Table name LOCATIONS
    # Model name Localizations
    def initialize_query
      @query = Actor.filter_actives.recent

      @query = @query.where(type: @levels) if @levels

      if @domains.present?
        @query = @query.joins(:categories).
          where({ categories: { id: @domains }})
      end

      if @start_date && !@end_date
        @query = @query.joins(:localizations).
                        where("locations.start_date >= ? OR locations.end_date >= ?",
                               @start_date.to_time.beginning_of_day, @start_date.to_time.beginning_of_day)
      end

      if @end_date && !@start_date
        @query = @query.joins(:localizations).
                        where("locations.end_date <= ? OR locations.start_date <= ?",
                               @end_date.to_time.end_of_day, @end_date.to_time.beginning_of_day)
      end

      if @start_date && @end_date
        @query = @query.joins(:localizations).
                        where("locations.start_date BETWEEN ? AND ? OR
                               locations.end_date BETWEEN ? AND ? OR
                               ? BETWEEN locations.start_date AND locations.end_date",
                               @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day, @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day, @start_date.to_time.beginning_of_day)
      end

      @query = @query.distinct
    end
end
