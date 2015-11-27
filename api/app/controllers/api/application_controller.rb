require 'application_responder'

module API
  class ApplicationController < ActionController::Base
    self.responder = ApplicationResponder
    respond_to :json
  end
end