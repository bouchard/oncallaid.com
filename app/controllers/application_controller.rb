class ApplicationController < ActionController::Base

  protect_from_forgery

  include OCAMarkdown

  helper :all

  helper_method :current_user

  layout :set_layout

  def current_user
    User.where(:id => session[:user_id]).first || User.new(:username => 'Guest')
  end

  # This method is used by the PaperTrail gem to store the user responsible for a model update.
  def user_for_paper_trail
    current_user.persisted? ? current_user : nil
  end

  # Extra information to store with each version.
  def info_for_paper_trail
    { :ip => request.remote_ip }
  end

  def local_request?
    local_addresses = ['127.0.0.1', '::1']
    (local_addresses.include?(request.remote_addr) && local_addresses.include?(request.remote_ip)) || Rails.env.development?
  end

  def redirect_back_or(default = nil, options = {})
    begin
      redirect_to(:back, options)
    rescue ActionController::RedirectBackError
      redirect_to(default || studies_path, options)
    end
  end

  def redirect_unless_logged_in
    raise CanCan::AccessDenied unless current_user && current_user.persisted?
  end

  private

  def set_layout
    request.xhr? ? nil : 'application'
  end

  rescue_from CanCan::AccessDenied do |e|
    logger.info('CanCan::AccessDenied') if Rails.env.development? || Rails.env.staging?
    if current_user.persisted?
      respond_to do |wants|
        wants.html { redirect_back_or root_path, :alert => "Sorry, but you don't have access to that." }
        wants.any { head :forbidden }
      end
    else
      session[:referrer] = request.url
      redirect_to new_session_path, :alert => "Please sign in or sign up to contribute to OnCallAid."
    end
  end

  rescue_from TWI::DuplicateProfileError, TWI::DuplicateEmailError do |e|
    redirect_back_or root_path, :alert => e.message
  end

end
