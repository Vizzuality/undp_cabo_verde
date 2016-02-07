module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the login page/
      '/account/login'
    when /the logout page/
      '/account/logout'
    when /the register page/
      '/account/register'
    when /the profile edit page for "(.*)"$/
      edit_user_registration_path(User.find_by_email($1))
    when /the dashboard page/
      dashboard_path
    when /the users page with filter active/
      '/manage/users?active=true'
    when /the user page for "(.*)"$/
      user_path(User.find_by_email($1))
    when /the edit user page for "(.*)"$/
      edit_user_path(User.find_by_email($1))
    when /the actors page with filter active/
      '/manage/actors?active=true'
    when /the user actors page for "(.*)"$/
      user_actors_path(User.find_by_email($1))
    when /the actor page for "(.*)"$/
      actor_path(Actor.find_by_name($1))
    when /the actor macro page for "(.*)"$/
      actor_macro_path(Actor.find_by_name($1))
    when /the edit actor page for "(.*)"$/
      edit_actor_path(Actor.find_by_name($1))
    when /the edit micro member actor page for "(.*)"$/
      membership_actor_path(Actor.find_by_name($1))
    when /the edit meso member actor page for "(.*)"$/
      membership_actor_path(Actor.find_by_name($1))
    when /the acts page with filter active/
      '/manage/actions?active=true'
    when /the user acts page for "(.*)"$/
      user_acts_path(User.find_by_email($1))
    when /the act page for "(.*)"$/
      act_path(Act.find_by_name($1))
    when /the edit act page for "(.*)"$/
      edit_act_path(Act.find_by_name($1))
    when /the edit micro member act page for "(.*)"$/
      membership_act_path(Act.find_by_name($1))
    when /the edit meso member act page for "(.*)"$/
      membership_act_path(Act.find_by_name($1))
    when /the categories page/
      '/manage/categories'
    when /the category page for "(.*)"$/
      category_path(Category.find_by_name($1))
    when /the edit category page for "(.*)"$/
      edit_category_path(Category.find_by_name($1))
    when /the new category page/
      new_category_path
    when /the indicators page/
      '/manage/indicators'
    when /the indicator page for "(.*)"$/
      indicator_path(Indicator.find_by_name($1))
    when /the edit indicator page for "(.*)"$/
      edit_indicator_path(Indicator.find_by_name($1))
    when /the new indicator page/
      new_indicator_path
    when /the indicators page with filter active/
      '/manage/indicators?active=true'
    when /the user indicators page for "(.*)"$/
      user_indicators_path(User.find_by_email($1))
    when /the units page/
      units_path
    when /the edit unit page for "(.*)"$/
      edit_unit_path(Unit.find_by_name($1))
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
