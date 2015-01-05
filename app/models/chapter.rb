class Chapter < ActiveRecord::Base

  has_many :articles

  attr_accessible :title, :sort_order

  validates_uniqueness_of :slug

  default_scope -> { order(:sort_order) }

  before_save :update_slug

  include Sortable

  private

  def update_slug
    self.slug = self.title.parameterize
  end

end
