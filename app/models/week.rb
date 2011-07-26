class Week < ActiveRecord::Base

  def submit
    self.submitted = 1
    self.save
  end

  def update_status(game_time)
    if Time.now > game_time
      self.played = 1
      self.save
    end    
  end
end
