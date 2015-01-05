class UsersController < ApplicationController

  skip_before_filter :hide_behind_http_auth, :only => [ :show ]

  # For pulling data in from The Inspired Network
  def show
    user = User.where(:id => params[:id]).first!
    render :json => user
  end

end
