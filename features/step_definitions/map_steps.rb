Then /^I should see all the (.+) markers$/ do |type|
  if type == 'actors'
    markersCount = Actor.all.size
    selector = '#map .js-actor-marker'
  else
    markersCount = Act.all.size
    selector = '#map .js-action-marker'
  end

  page.has_css?(selector, :count => markersCount)
end

Then /^I click on the (.+)'s marker with id (.+)$/ do |type, id|
  page.find('#map .js-' + type + '-marker[data-id="' + id + '"]').click
end
