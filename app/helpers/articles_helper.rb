module ArticlesHelper

  def link_to_edit_submission(s)
    link_text = 'Contribute'
    link_text = 'Submission Rejected' if s.rejected.count > 0
    link_text = 'Submission Pending' if s.pending.count > 0
    link_to(link_text, edit_article_path(@article), :class => 'action-link button has-tipsy', :'data-tipsy-text' => 'Have a correction or addition to make? Click here to sign in!')
  end

end
