class SubmissionMailer < ActionMailer::Base
  default from: 'The Inspired Network Submissions <submissions@thewellinspired.com>'

  def new_submission(submission_id)
    @submission = Submission.where(:id => submission_id).first
    mail(
      :to => User.all.select{ |u| u.can? :update, Article.new }.map{ |u| "#{u.username.gsub(/[^0-9A-Za-z]/i, '')} <#{u.email}>"},
      :subject => "[OCA] New Submission for Article '#{@submission.article.title}'"
    )
  end

  def notify_accepted(submission_id)
    @submission = Submission.where(:id => submission_id).first
    mail(
      :to => "#{@submission.user.username.gsub(/[^0-9A-Za-z]/i, '')} <#{@submission.user.email}>",
      :subject => "[OCA] Your Contribution to '#{@submission.article.title}' Has Been Accepted!"
    )
  end

  def notify_rejected(submission_id)
    @submission = Submission.where(:id => submission_id).first
    mail(
      :to => "#{@submission.user.username.gsub(/[^0-9A-Za-z]/i, '')} <#{@submission.user.email}>",
      :subject => "[OCA] Please review your article submission to OnCallAid"
    )
  end
end
