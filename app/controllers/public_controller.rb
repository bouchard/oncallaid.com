class PublicController < ApplicationController

  def attribution
  end

  def disclaimer
    render :layout => false
  end

end
