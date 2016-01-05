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

  def initialize_query
    @query = Actor.filter_actives.recent

    @query = @query.where(type: @levels) if @levels

    if @socio_cultural_domains
      @query = @query.joins(:socio_cultural_domains).
        where(socio_cultural_domains: { id: @socio_cultural_domains })
    end

    @query = @query
  end
end
