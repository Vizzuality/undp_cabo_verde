class Search::ActsParams < Hash
  def initialize(params)
    sanitized_params = {
      levels: params[:levels] && (params[:levels] & ["meso", "macro", "micro"]).
        present? ? params[:levels].map{|t| "Act"+t.titleize} : nil,
      domains: params[:domains_ids].blank?  ?
        [] : params[:domains_ids].map(&:to_i),
      start_date: params[:start_date] || nil,
      end_date: params[:end_date] || nil,
      page: params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1,
      per_page: params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : 25,
      model_name: params[:model_name] || nil,
      relation_name: params[:relation_name] || nil
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
