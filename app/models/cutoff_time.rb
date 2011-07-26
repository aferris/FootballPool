class CutoffTime < ActiveRecord::Base
  validates_presence_of :week, :cutoff_time
  validates_uniqueness_of :week

  def cutoff
    if Time.now > self.cutoff_time
      result = true
    else
      result = false
    end
    
    result
  end

  def self.get_this_week
    week = nil
    
    @cutoff_times = CutoffTime.find(:all, :order => 'week')
    for cutoff_time in @cutoff_times
      if cutoff_time.cutoff
        updated_cutoff = cutoff_time
      else
        break
      end
    end
    
    if updated_cutoff
      week = updated_cutoff.week
    end
    
    return week
  end
  
  def self.get_next_week
    week = nil
    
    @cutoff_times = CutoffTime.find(:all, :order => 'week')
    for cutoff_time in @cutoff_times
      if !cutoff_time.cutoff
        break
      end
    end
    
    if cutoff_time
      week = cutoff_time.week
    end
    
    return week
  end
end
