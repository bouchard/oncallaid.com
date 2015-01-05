class Article < ActiveRecord::Base

  belongs_to :chapter, :touch => true

  has_paper_trail :class_name => 'ArticleVersion'

  has_many :contributions
  has_many :submissions

  attr_accessible :title, :body, :chapter_id

  validates_uniqueness_of :slug, :scope => [ :chapter_id ]
  validates_length_of :title, :minimum => 1
  validates_uniqueness_of :title

  default_scope -> { where(:deleted => false).order(:sort_title) }

  before_save :update_slug
  before_save :update_sort_title
  before_save :clean_newlines
  before_save :update_empty

  def contribution_counts
    c = self.contributions.order('SUM(contributions.word_size) DESC').select('contributions.*, SUM(contributions.word_size) AS word_count, SUM(contributions.line_size) AS line_count').having('SUM(contributions.word_size) > 0').includes(:user).group(all_columns(:contributions))
    require 'ostruct'
    c.collect do |c|
      OpenStruct.new({
        :user => c.user,
        :word_count => c.word_count.to_i,
        :line_count => c.line_count.to_i
      })
    end
  end

  private

  def update_empty
    self.empty = self.body.nil? || self.body.empty? || self.body.length < 10
    return true
  end

  def update_slug
    self.slug = self.title.parameterize if self.title_changed?
    return true
  end

  def update_sort_title
    self.sort_title = self.title.gsub(/^(the|a|an)\s/i,'') if self.title_changed?
    return true
  end

  def clean_newlines
    self.body.gsub!(/\r\n?/,"\n") rescue nil
    return true
  end

end
