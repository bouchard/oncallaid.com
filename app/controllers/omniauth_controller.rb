class OmniauthController < ApplicationController

  def failure
  end

  def the_inspired_network
    authorize_omniauth(:the_inspired_network)
  end

  protected

  def authorize_omniauth(kind)
    @user = User.find_for_oauth(env['omniauth.auth'], current_user)

    if @user.persisted? && @user.errors.empty?
      flash[:notice] = 'Successfully signed you in!'
      session[:user_id] = @user.id
      if session[:referrer] && session[:referrer].match(/^https?:\/\/oncallaid.com.*/)
        redirect_to session.delete(:referrer)
      else
        redirect_to root_path
      end
    else
      flash[:alert] = 'Failed to sign you in, sorry!'
      if session[:referrer] && session[:referrer].match(/^https?:\/\/oncallaid.com.*/)
        redirect_to session.delete(:referrer)
      else
        redirect_to root_path
      end
    end
  end

end