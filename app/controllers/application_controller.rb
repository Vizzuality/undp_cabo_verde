class ApplicationController < ActionController::Base
  before_action :menu_highlight
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  private
  
    def menu_highlight
      @menu_highlighted = :none
    end
end
