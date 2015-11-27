require 'application_responder'

class ApplicationController < ActionController::Base
  before_action :expire_sts_headers
  before_action :menu_highlight
  
  protect_from_forgery with: :exception

  self.responder = ApplicationResponder
  respond_to :html

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def after_sign_in_path_for(*)
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
