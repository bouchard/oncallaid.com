OnCallAid::Application.routes.draw do

  HOSTNAME = 'network.thewellinspired.com' + (Rails.env.production? ? '' : '.dev')

  ## Stub out routes for forwarding on to the Inspired Network.
  ## Need to hit the Rack session directly as our router doesn't have any idea about our application.
  get '/users/sign_in' => redirect { |p, r|
    # We may have already set the referrer from CanCan::AccessDenied
    r.session[:referrer] ||= r.referrer
    r.session[:type] = 'signin'
    r.session[:message] = r.flash[:alert] || r.flash[:notice]
    r.flash[:alert] = r.flash[:notice] = nil
    '/auth/the_inspired_network'
  }, :as => :new_session

  get '/users/sign_up' => redirect { |p, r|
    # We may have already set the referrer from CanCan::AccessDenied
    r.session[:referrer] ||= r.referrer
    r.session[:type] = 'signup'
    r.session[:message] = r.flash[:alert] || r.flash[:notice]
    r.flash[:alert] = r.flash[:notice] = nil
    '/auth/the_inspired_network'
  }, :as => :new_registration

  get '/auth/:action/callback' => 'omniauth#:action', :as => :omniauth_callback
  get '/auth/failure' => 'omniauth#failure', :as => :omniauth_failure

  delete '/users/sign_out' => redirect { |p, r|
    r.session[:user_id] = nil
    r.flash[:notice] = "Successfully signed you out."
    "#{r.scheme}://#{HOSTNAME}/users/sign_out?redirect_to=#{r.referer || '/'}"
  }, :as => :destroy_session

  resources :users, :only => [ :show ]

  controller :public do
    get :attribution
    get :contributors
    get :disclaimer
    get :ios
  end

  get 'feedback', :to => 'feedback#new', :as => 'feedback'
  post 'feedback', :to => 'feedback#create'

  resources :chapters, :only => [ :show ]
  # We still want the #show action on articles so we can redirect to the slug path.
  resources :articles do
    collection do
      get :xml
    end
  end
  resources :submissions do
    member do
      get    :moderate
      put    :accept
      delete :reject
    end
  end
  # Needs to go last as it's a catch-all...
  get ':chapter_slug/:slug' => 'articles#show', :as => :slug, :constraints => { :format => 'html' }

  root :to => 'articles#index'
end
