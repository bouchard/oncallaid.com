class Profile < ActiveRecord::Base

  attr_accessible :description, :name, :postnominals, :title, :user_id

  belongs_to :user

end
