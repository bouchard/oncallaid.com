class ArticleVersion < PaperTrail::Version

  self.table_name = :article_versions

  attr_accessible :diff_word_size, :diff_line_size, :ip

  has_one :contribution, :dependent => :destroy

  before_save :calculate_diffs
  after_save :update_contribution

  # Allow articles to be found without their default scope applied in PaperTrail.
  # http://stackoverflow.com/questions/1540645/how-to-disable-default-scope-for-a-belongs-to
  def item
    Article.unscoped { super }
  end

  def update_contribution
    c = self.contribution || calc_and_build_contribution
    c.word_size = self.diff_word_size
    c.line_size = self.diff_line_size
    c.save! if c.changed?
  end

  private

  def calc_and_build_contribution
    self.build_contribution(
      :article_id => self.item.id,
      :user_id => self.whodunnit.respond_to?(:id) ? self.whodunnit.id : self.whodunnit
    )
  end

  def calculate_diffs
    self.diff_word_size = calculate_diff_size(:word)
    self.diff_line_size = calculate_diff_size(:line)
  end

  def calculate_diff_size(type)
    raise ArgumentError unless type.in?([:word, :line])
    regex = type == :word ? /\W+/ : /\n+/
    require 'diff/lcs'
    if !self.persisted? || self.next.nil?
      # self.item gets cached with the reified version, so we want to make sure we have fresh versions of both to compare.
      a = self.reify.try(:body) || ''
      b = self.item.reload && (self.item.body || '')
      Diff::LCS.sdiff(a.split(regex), b.split(regex)).select{ |d| d.action == '+' }.length
    else
      # self.item gets cached with the reified version, so we want to make sure we have fresh versions of both to compare.
      a = self.reify.try(:body) || ''
      b = self.next.reify.try(:body) || ''
      Diff::LCS.sdiff(a.split(regex), b.split(regex)).select{ |d| d.action == '+' }.length
    end
  end

end