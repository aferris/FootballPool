class Pick < ActiveRecord::Base
  belongs_to :game
  belongs_to :user
  belongs_to :team

  validates_uniqueness_of :game_id, :scope => [:user_id]
  validates_presence_of :user_id, :game_id, :team_id, :week
  
  def self.create_pick(pick, user_id, game_id, week)
    item = self.new
    item.user_id = user_id
    item.game_id = game_id
    item.team_id = pick
    item.week = week
    item.point = 0
    
    item
  end
  
  def self.update_points(game_id)
    picks = Pick.find(:all, :conditions =>["game_id = ?", game_id])
    winning_team = Game.find_winner(game_id)

    for pick in picks
      if winning_team and winning_team.id == pick.team_id
        pick.point = 1
      else
        pick.point = 0
      end
      
      pick.save
    end
  end

end
