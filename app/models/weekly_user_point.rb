class WeeklyUserPoint < ActiveRecord::Base
  belongs_to :tiebreaker
  belongs_to :user
  
  validates_uniqueness_of :week, :scope => [:user_id]
  validates_presence_of   :week, :user_id

  def self.order_weekly_winner_list(week, tiebreaker_points)
    max_points = maximum('points', :conditions => ['week = ?', week])
    if !max_points.nil? and max_points > 0
		# get the sorted list by how far away from the tiebreaker they are
		winners = where("week = ? and points = ?", week, max_points).sort { 
			| a, b | 
			a.tie_diff(tiebreaker_points) <=> b.tie_diff(tiebreaker_points)
			}
	end
	
	winners
  end
  
  def self.find_weekly_winner(week)
	@winner = []

	tiebreaker_game = where(:week => week).first.tiebreaker.game

	if Time.now > tiebreaker_game.game_time
		tiebreaker_points = tiebreaker_game.home_score + tiebreaker_game.away_score
		
		best_tie = -1
		
		winner_list = order_weekly_winner_list(week, tiebreaker_points)
		winner_list.each do | a |
			if best_tie == -1
				@winner << a
				best_tie = a.tiebreaker.points
			elsif a.tiebreaker.points == best_tie
				@winner << a
			else
				break
			end
		end
	end
	
	@winner
  end
  
  def self.find_leaders(week, max_points)
    if max_points > 0
      final_leaders = Array.new
      
      leaders = where("week = ? and points = ?", week, max_points)
      next_leaders =  where("week = ? and points = ?", week, max_points - 1)
      
      # start with the leaders
      final_leaders = leaders

      if !next_leaders.empty?
        tiebreaker_game = Tiebreaker.where(:week =>, week).first
      
        # if the leaders are unanimous in their tiebreaker game pick, the runners up cannot win
        both_picked = 0
        tb_pick = 0
        for leader in leaders
          pick = Pick.where('week = ? and user_id = ? and game_id = ?', week, leader.user_id, tiebreaker_game.game_id).first
          
          if tb_pick == 0
            tb_pick = pick.team_id
          elsif tb_pick != pick.team_id
            both_picked = 1
          end
        end
        
        #if the leaders are unanimous, only the next leaders that picked opposite can win
        if both_picked == 0
          for next_leader in next_leaders
            next_pick = Pick.where('week = ? and user_id = ? and game_id = ?', week, next_leader.user_id, tiebreaker_game.game_id).first
            if next_pick.team_id != tb_pick
              final_leaders << next_leader
            end
          end
        end
      end
    end
    
    final_leaders
  end

  def tie_diff(game_score)
	(tiebreaker.points - game_score).abs
  end
    
  def update_user_week(userPicks)

    self.points = 0

    picks = Pick.where("week = ? and user_id = ?", self.week, self.user_id)

    for pick in picks
      game = Game.find(pick.game_id)
      if game.winner == pick.team_id
        self.points += 1
      end
    end

    self.save
  end
end
