module ApplicationHelper
  def menu_highlight?(page_identifier)
    page_identifier == @menu_highlighted
  end
end
