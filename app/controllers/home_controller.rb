class HomeController < ApplicationController
  
  def index
  end

  private
  
    def menu_highlight
      @menu_highlighted = :home
    end
end
