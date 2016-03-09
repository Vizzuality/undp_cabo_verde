class HomeController < ApplicationController

  def index
    actors = Actor.recent.limit(5)
    acts = Act.recent.limit(5)
    @objs = (actors.to_a + acts.to_a).
      sort{| a,b| a.updated_at <=> a.updated_at }
  end

  private

    def menu_highlight
      @menu_highlighted = :home
    end
end
