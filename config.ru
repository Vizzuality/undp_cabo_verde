# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application

if ENV['ACCESS'] == 'private'
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == ENV['ACCESS_USER']
    password  == ENV['ACCESS_PASSWORD']
  end
end