class ApplicationController < ActionController::Base
  before_action :expire_sts_headers
  before_action :menu_highlight
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  private

    def expire_sts_headers
      response.headers['Strict-Transport-Security'] = 'max-age=0' if ENV['FORCE_NON_SSL'] == 'true'
    end
  
    def menu_highlight
      @menu_highlighted = :none
    end
end
