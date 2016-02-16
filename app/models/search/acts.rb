class Search::Acts
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
      @options = Search::ActsParams.sanitize(options)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end

    def initialize_query
      @query = Act.recent

      @query = @query.where(type: @levels) if @levels

      if @domains.present?
        @query = @query.joins(:categories).
          where({ categories: { id: @domains }})
      end

      if @search_term.present?
        @query = @query.where("acts.name ILIKE ? OR acts.alternative_name ILIKE ? OR acts.short_name ILIKE ? OR acts.description ILIKE ?", "%#{@search_term}%", "%#{@search_term}%", "%#{@search_term}%", "%#{@search_term}%")
      end

      if @start_date || @end_date
        @first_date  = (Time.zone.now - 50.years).beginning_of_day
        @second_date = (Time.zone.now + 50.years).end_of_day
      end

      if @start_date && !@end_date
        @query = @query.where("COALESCE(start_date, '#{@first_date}') >= ? OR
                               COALESCE(end_date, '#{@second_date}') >= ?",
                               @start_date.to_time.beginning_of_day, @start_date.to_time.beginning_of_day)
      end

      if @end_date && !@start_date
        @query = @query.where("COALESCE(end_date, '#{@second_date}') <= ? OR
                               COALESCE(start_date, '#{@first_date}') <= ?",
                               @end_date.to_time.end_of_day, @end_date.to_time.beginning_of_day)
      end

      if @start_date && @end_date
        @query = @query.where("COALESCE(start_date, '#{@first_date}') BETWEEN ? AND ? OR
                               COALESCE(end_date, '#{@second_date}') BETWEEN ? AND ? AND
                               ? BETWEEN COALESCE(start_date, '#{@first_date}') AND COALESCE(end_date, '#{@second_date}')",
                               @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                               @start_date.to_time.beginning_of_day, @end_date.to_time.end_of_day,
                               @start_date.to_time.beginning_of_day)
      end

      @query = @query.distinct
    end
end
