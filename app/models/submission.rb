class Submission < ActiveRecord::Base

  belongs_to :article
  belongs_to :user

  # Title isn't accessible as we set it automatically to match the article's title.
  attr_accessible :body

  validates_presence_of :user
  validates_length_of :title, :minimum => 1
  validates_length_of :body, :minimum => 1, :message => 'Your edit is too short.'
  validates_uniqueness_of :body, :scope => :user_id, :message => "Oops, looks like you've already submitted this edit!"

  validate :must_be_different, :on => :create
  validates :status, :inclusion => { :in => %w(pending rejected accepted) }

  after_initialize :pull_article_data

  scope :pending, -> { where(:status => 'pending') }
  scope :rejected, -> { where(:status => 'rejected') }
  scope :accepted, -> { where(:status => 'accepted') }
  scope :not_accepted, -> { where(%|submissions.status != 'accepted'|) }

  def must_be_different
    errors.add(:body, "You haven't made any changes.") if self.body == self.article.body
  end

  def accept!
    w = PaperTrail.whodunnit
    PaperTrail.whodunnit = self.user
    Article.paper_trail_off if self.article.originator == self.user.to_s
    self.article.update_attributes!({
      :title => self.title,
      :body => self.body
    })
    PaperTrail.whodunnit = w
    self.status = 'accepted'
    self.save!
    SubmissionMailer.notify_accepted(self.id).deliver
  end

  def reject!
    self.status = 'rejected'
    self.save!
    SubmissionMailer.notify_rejected(self.id).deliver
  end

  private

  def pull_article_data
    self.title = self.article.title
    self.body ||= self.article.body
  end

end
