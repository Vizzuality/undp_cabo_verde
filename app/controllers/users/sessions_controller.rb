class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: :create
  before_action :destroy_session,          only: :destroy

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  private

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.for(:sign_in) << :attribute
    end

    def destroy_session
      current_user.check_authentication_token(destroy_true: true)
    end

    def menu_highlight
      @menu_highlighted = :none
    end
end
