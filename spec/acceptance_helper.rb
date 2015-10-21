require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format = :json
  config.curl_headers_to_filter = nil
  config.curl_host = 'http://umdp-cabo-verde.herokuapp.com'
  config.api_name  = "API UMDP Cabo Verde"
end

Raddocs.configure do |config|
  config.docs_dir   = "api/docs"
  config.api_name   = "API UMDP Cabo Verde"
end