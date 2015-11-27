require 'responders'

module API
  class Engine < ::Rails::Engine
    isolate_namespace API
  end
end