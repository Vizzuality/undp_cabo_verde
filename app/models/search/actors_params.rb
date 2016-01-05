class Search::ActorsParams < Hash
  def initialize(params)
    sanitized_params = {
      levels: params[:levels] && (params[:levels] & ["meso", "macro", "micro"]).
        present? ? params[:levels].map{|t| "Actor"+t.titleize} : nil,
      socio_cultural_domains: params[:socio_cultural_domains_ids].blank?  ?
        nil : params[:socio_cultural_domains_ids],
      other_domains: params[:other_domains_ids].blank? ?
        nil : params[:other_domains_ids],
      start_date: params[:start_date] || nil,
      end_date: params[:end_date] || nil,
      page: params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1,
      per_page: params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : 25
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
