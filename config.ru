# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application

use Rack::Deflater

if ENV['ACCESS'] == 'private'
  use Rack::Auth::Basic, 'Restricted Area' do |username, password|
    username if username == ENV['ACCESS_USER']
    password if password == ENV['ACCESS_PASSWORD']
  end
end