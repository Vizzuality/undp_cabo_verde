require 'application_responder'

module API
  class ApiBaseController < ActionController::Base
    self.responder = ApplicationResponder
    respond_to :json
  end
end