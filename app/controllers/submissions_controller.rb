class SubmissionsController < ApplicationController

  def new
    # Show errors as flash messages. Maybe change this to inline later?
    #flash[:alert]
    return redirect_back_or unless session[:new_submission_article_id]
    @article = Article.where(:id => session[:new_submission_article_id]).first!
    @submission = @article.submissions.not_accepted.where(:user_id => current_user.id).first_or_initialize
    @submission.assign_attributes(params[:submission])
    return redirect_to edit_submission_path(@submission) if @submission.persisted?
  end

  def create
    @article = Article.where(:id => session[:new_submission_article_id]).first!
    @submission = @article.submissions.new(params[:submission])
    @submission.user = current_user
    if @submission.save
      session[:new_submission_article_id] = nil
      SubmissionMailer.new_submission(@submission.id).deliver
      redirect_to slug_path(:chapter_slug => @article.chapter.slug, :slug => @article.slug), :notice => 'Thanks, submission saved!'
    else
      flash[:alert] = @submission.errors.messages.values.join(' ')
      render :new
    end
  end

  def edit
    @submission = current_user.submissions.where(:id => params[:id]).first!
    @article = @submission.article
    render :new
  end

  def update
    @submission = current_user.submissions.where(:id => params[:id]).first!
    params[:submission] = params[:submission].slice(:body).merge({
      :rejected_reason => nil,
      :status => 'pending'
    })
    if @submission.update_attributes(params[:submission], :without_protection => true)
      session[:new_submission_article_id] = nil
      redirect_to slug_path(:chapter_slug => @submission.article.chapter.slug, :slug => @submission.article.slug), :notice => 'Thanks, submission updated!'
    else
      flash[:alert] = @submission.errors.messages.values.join(' ')
      render :new
    end
  end

  def moderate
    @submission = Submission.where(:id => params[:id]).first!
    authorize! :update, @submission.article
  end

  def accept
    @submission = Submission.where(:id => params[:id]).first!
    authorize! :update, @submission.article
    @submission.update_attributes!(params[:submission])
    @submission.accept!
    redirect_to slug_path(:chapter_slug => @submission.article.chapter.slug, :slug => @submission.article.slug), :notice => 'Submission accepted!'
  end

  def reject
    @submission = Submission.where(:id => params[:id]).first!
    authorize! :update, @submission.article
    # For saving the rejected_reason.
    @submission.update_attributes(params[:submission])
    @submission.reject!
    redirect_to slug_path(:chapter_slug => @submission.article.chapter.slug, :slug => @submission.article.slug), :notice => 'Submission rejected.'
  end

  def destroy
    @submission = current_user.submissions.where(:id => params[:id]).first!
    article = @submission.article
    @submission.destroy
    redirect_to slug_path(:chapter_slug => article.chapter.slug, :slug => article.slug), :notice => 'Submission deleted.'
  end

end
