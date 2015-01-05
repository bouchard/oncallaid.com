class FeedbackController < ApplicationController

  def new
    authorize! :send, :feedback
  end

  def create
    authorize! :send, :feedback
    return render :new unless params[:body] && params[:body].length > 1
    FeedbackMailer.feedback_mail(current_user.id, params[:body]).deliver
  end

end
