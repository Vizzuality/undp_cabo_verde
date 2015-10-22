class ApplicationController < ActionController::Base

  before_action :menu_highlight
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
    def menu_highlight
      @menu_highlighted = :none
    end
  
end
