class FeedbackMailer < ActionMailer::Base
  default to: 'support@thewellinspired.com'

  def feedback_mail(user_id, body)
    @body = body
    u = User.where(:id => user_id).first
    mail(:from => "#{u.username} <#{u.email}>", :subject => 'OnCallAid Feedback')
  end

end
