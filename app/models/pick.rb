class Pick < ActiveRecord::Base
  belongs_to :game
  belongs_to :user
  belongs_to :team

  validate :game_id, :uniqueness => {:scope => :user_id}, :presence => true
  validate :user_id, :presence => true
  validate :team_id, :presence => true
  validate :week, :presence => true
  
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
    picks = where(:game_id => game_id)
    winning_team = Game.find_winner(game_id)

    picks.each do | pick |
      if winning_team and winning_team.id == pick.team
        pick.point = 1
      else
        pick.point = 0
      end
      
      pick.save
    end
  end

end
