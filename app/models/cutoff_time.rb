class CutoffTime < ActiveRecord::Base
  validate :week, :presence => true, :uniqueness => true
  validate :cutoff_time, :presence => true

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
    
    CutoffTime.order('week').each do |cutoff_time|
      if cutoff_time.cutoff
        updated_cutoff = cutoff_time
      else
        break
      end
    end
    
    if !updated_cutoff.nil?
      week = updated_cutoff.week
    end
    
    return week
  end
  
  def self.get_next_week
    week = nil
    
    CutoffTime.order('week').each do |cutoff_time|
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
