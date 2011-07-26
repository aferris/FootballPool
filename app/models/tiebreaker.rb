class Tiebreaker < ActiveRecord::Base
  has_one :weekly_user_point
  belongs_to :game
  belongs_to :user
  
  validates_uniqueness_of :week, :scope => [:user_id]
  validates_presence_of   :week, :user_id
  
end
