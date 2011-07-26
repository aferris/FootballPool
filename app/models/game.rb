class Game < ActiveRecord::Base
  validates_presence_of :week, :hometeam_id, :awayteam_id
  validates_uniqueness_of :week, :scope => [:hometeam_id]
  validates_uniqueness_of :week, :scope => [:awayteam_id]

  has_one :tiebreaker
  
  def update_winner
    if self.home_score > self.away_score
      self.winner = self.hometeam_id
    elsif self.home_score < self.away_score
      self.winner = self.awayteam_id
    else
      self.winner = 0
    end
    
    self.update_attribute('winner', self.winner)
  end

  def self.find_winner(game_id)
    game = Game.find(game_id)

    if game.winner > 0
      winner = Team.find(game.winner)
    end
      
    winner
  end

  def find_winner
    if self.winner > 0
      winner = Team.find(self.winner)
    end

    winner
  end

  def find_winner(hometeam, awayteam)
    if self.winner > 0
      if self.winner == self.hometeam_id
        winner = hometeam
      elsif self.winner == self.awayteam_id
        winner = awayteam
      end
    end

    winner
  end

  def find_loser
    if self.winner > 0
      if self.winner == self.hometeam_id
        loser = Team.find(self.awayteam_id)
      elsif self.winner == self.awayteam_id
        loser = Team.find(self.hometeam_id)
      end
    end
      
    loser
  end

  def find_loser(hometeam, awayteam)
    if self.winner > 0
      if self.winner == self.hometeam_id
        loser = awayteam
      elsif self.winner == self.awayteam_id
        loser = hometeam
      end
    end
      
    loser
  end

  def update_score(home_score, away_score)
    self.home_score = home_score
    self.away_score = away_score
    
    self.save
  end

  def update_home_score(score)
    self.home_score = score

    self.save
  end

  def update_away_score(score)
    self.away_score = score

    self.save
  end
  
  def self.get_team_schedule(team)
    team_games = where('hometeam_id = ? or awayteam_id = ?', team, team.order('week')
    
    team_games
  end
end
