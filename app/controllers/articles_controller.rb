class ArticlesController < ApplicationController

  # etag { current_user.try(:id) }

  def index
    @chapters = Chapter.all
    # fresh_when(@chapters.map(&:articles))
  end

  def show
    begin
      @article = Article.where(:slug => params[:slug]).first!
      @user_submission_scope = @article.submissions.not_accepted.where(:user_id => current_user.id)
      fresh_when(@article)
    rescue ActiveRecord::RecordNotFound
      if @article = Article.where(:id => params[:id]).first
        return redirect_to slug_path(:chapter_slug => @article.chapter.slug, :slug => @article.slug)
      else
        return head :not_found
      end
    end
  end

  def new
    # Dead links in article copy are linked to new article with a 'title' param.
    params[:article] ||= {}
    title = params[:article][:title] || params[:title]
    @article = Article.new(params[:article].merge(:title => title))
    authorize! :create, @article
    render :edit
  end

  # Redirect to new submission unless we're an admin or moderator.
  def edit
    begin
      @article = Article.where(:id => params[:id]).first!
      if cannot? :update, @article
        @submission = @article.submissions.new(:body => @article.body)
        authorize! :create, @submission
        session[:new_submission_article_id] = @submission.article_id
        return redirect_to new_submission_path
      end
    rescue ActiveRecord::RecordNotFound
      return head :not_found
    end
  end

  def create
    begin
      authorize! :create, Article.new
      @article = Article.create!(params[:article])
      redirect_to edit_article_path(@article)
    rescue ActiveRecord::RecordInvalid
      render :edit
    end
  end

  def update
    begin
      @article = Article.where(:id => params[:id]).first!
      authorize! :update, @article
    rescue ActiveRecord::RecordNotFound
      return head :not_found
    end
    Article.paper_trail_off if @article.originator == current_user.id.to_s
    if @article.update_attributes(params[:article])
      redirect_to edit_article_path(@article), :notice => 'Article saved!'
    else
      redirect_to edit_article_path(@article), :alert => 'Article invalid.'
    end
  end

  def xml
    authorize! :manage, Article.new if Rails.env.production?
    render :xml => Chapter.all.to_xml(:include => :articles)
  end

end