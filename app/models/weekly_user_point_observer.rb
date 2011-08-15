class WeeklyUserPointObserver < ActiveRecord::Observer
  def after_save(wup)
    wup.user.total_user_point.update_user_season
  end
end