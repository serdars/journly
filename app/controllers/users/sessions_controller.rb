class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # During sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    render :json => {
      'csrfParam' => request_forgery_protection_token,
      'csrfToken' => form_authenticity_token
    }
  end

  # During sign in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    render :json => {
      'user' => current_user,
      'csrfParam' => request_forgery_protection_token,
      'csrfToken' => form_authenticity_token
    }
  end
end
