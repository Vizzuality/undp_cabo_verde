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
      @query = Act.filter_actives.recent

      @query = @query.where(type: @levels) if @levels

      if @domains.present?
        @query = @query.joins(:categories).
          where({ categories: { id: @domains }})
      end

      if @start_date
        @query = @query.where('start_date > ?', @start_date)
      end

      if @end_date
        @query = @query.where('end_date < ?', @end_date)
      end

      @query = @query
    end
end