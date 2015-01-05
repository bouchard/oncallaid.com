# Don't load on asset precompile.
unless ENV['RAILS_GROUPS'] == 'assets'
  require 'omniauth-oauth2'

  module OmniAuth
    module Strategies
      class TheInspiredNetwork < OAuth2

        if Rails.env.production?
          SITE_URL = 'https://network.thewellinspired.com'
        else
          SITE_URL = 'http://network.thewellinspired.com.dev'
        end

        option :name, 'the_inspired_network'

        option :client_options, {
          :site => SITE_URL,
          :authorize_url => "#{SITE_URL}/authorize",
          :token_url => "#{SITE_URL}/access_token",
          :ssl => { :verify => Rails.env.production? }
        }

        uid { user_info['user']['id'] }

        info { user_info }

        def user_info
          access_token.params['me']['info']
        end

        # Allows us to piggyback on the request with which type (sign in or sign up).
        def request_phase
          type = (request.session[:type] && request.session[:type].match('signin')) ? 'signin' : 'signup'
          redirect client.auth_code.authorize_url(
            {
              :redirect_uri => callback_url,
              :type => type,
              :message => request.session[:message]
            }.merge(authorize_params)
          )
        end

      end
    end
  end

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :the_inspired_network, ENV['OCA_CLIENT_ID'], ENV['OCA_CLIENT_SECRET']
  end
end