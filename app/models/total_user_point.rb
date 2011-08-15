class TotalUserPoint < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :user_id
  validates_presence_of   :user_id, :points

  def update_user_season
    self.points = 0

    wup = self.user.weekly_user_points
    wup.each do |user_week|
      self.points += user_week.points
    end
          
    self.save
  end  
=begin
  def update_user_season(week, year)
    user_week = WeeklyUserPoint.find(:first, :conditions => ["week = ? and user_id = ? and year = ?", week, self.user_id, year])
    if user_week
      self.points += user_week.points
    end
      
    self.save
  end  
=end
  def calculate_whole_user_season
    self.points = 0

    week = 1
    while week <= 17
      self.update_user_season(week)
      
      week += 1
    end
    
    self.save
  end  
end
