require 'application_responder'

class ApplicationController < ActionController::Base
  before_action :expire_sts_headers
  before_action :menu_highlight
  after_action  :store_location

  protect_from_forgery with: :exception

  self.responder = ApplicationResponder
  respond_to :html

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def store_location
  return unless request.get?
    if (request.path != '/account/login' &&
        request.path != '/account/register' &&
        request.path != '/account/secret/new' &&
        request.path != '/account/secret/edit' &&
        request.path != '/account/logout' &&
        request.path != '/account/edit' &&
        request.path != '/account/password' &&
        request.path != '/account/cancel' &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  private

    def after_sign_in_path_for(*)
      session[:previous_url] || root_path
    end

    def expire_sts_headers
      response.headers['Strict-Transport-Security'] = 'max-age=0' if ENV['FORCE_NON_SSL'] == 'true'
    end

    def menu_highlight
      @menu_highlighted = :none
    end
end
