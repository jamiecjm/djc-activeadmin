class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :name, :prefered_name, :phone_no, :birthday, :parent_id, :location])
  end

  def access_denied(exception=nil)
    redirect_to root_path, alert: 'Access Denied'
  end

  def approved_user_only
  	unless current_user&.approved?
  		sign_out current_user 
  		redirect_to new_user_session_path, alert: 'Access Denied'
  	end
  end

end
