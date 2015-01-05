class Contribution < ActiveRecord::Base
  attr_accessible :line_size, :user_id, :word_size, :article_id
  belongs_to :user
  belongs_to :article_version
  belongs_to :article
end
