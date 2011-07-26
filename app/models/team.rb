class Team < ActiveRecord::Base
  has_many :picks

  validates_presence_of :name, :abbreviation
  validates_uniqueness_of :name, :abbreviation

  def update_losses
    self.losses += 1
  end

  def update_wins
    self.wins += 1
  end
  
  def update_home_losses
    self.home_losses += 1
  end

  def update_home_wins
    self.home_wins += 1
  end
  
  def update_away_losses
    self.away_losses += 1
  end

  def update_away_wins
    self.away_wins += 1
  end
  
  def update_conf_losses
    self.conf_losses += 1
  end

  def update_conf_wins
    self.conf_wins += 1
  end
  
  def update_division_losses
    self.division_losses += 1
  end

  def update_division_wins
    self.division_wins += 1
  end
  
  def update_streak(streak, winlose)
    if winlose == 'win'
      update_win_streak(streak)
    elsif winlose == 'lose'
      update_lose_streak(streak)
    else
      clear_streak(streak)
    end
  end
  
  def self.update_ties(hometeam, awayteam, game)
    hometeam.ties += 1
    awayteam.ties += 1

    hometeam.home_ties += 1
    awayteam.away_ties += 1

    if winner.conference == loser.conference
      hometeam.conf_ties += 1
      awayteam.conf_ties += 1
    end

    if winner.division == loser.division
      hometeam.division_ties += 1
      awayteam.division_ties += 1
    end
  end
  
  def self.update_points(hometeam, awayteam, game)    
    hometeam.points_for += game.home_score
    hometeam.points_against += game.away_score  

    awayteam.points_for += game.away_score
    awayteam.points_against += game.home_score
  end

private

  def update_win_streak(streak)
    if streak == 'home'
      self.home_lose_streak = 0
      self.home_win_streak += 1
    elsif streak == 'away'
      self.away_lose_streak = 0
      self.away_win_streak += 1
    elsif streak == 'division'
      self.div_lose_streak = 0
      self.div_win_streak += 1
    elsif streak == 'conf'
      self.conf_lose_streak = 0
      self.conf_win_streak += 1
    else
      self.lose_streak = 0
      self.win_streak += 1
    end
  end

  def update_lose_streak(streak)
    if streak == 'home'
      self.home_win_streak = 0
      self.home_lose_streak += 1
    elsif streak == 'away'
      self.away_win_streak = 0
      self.away_lose_streak += 1
    elsif streak == 'division'
      self.div_win_streak = 0
      self.div_lose_streak += 1
    elsif streak == 'conf'
      self.conf_win_streak = 0
      self.conf_lose_streak += 1
    else
      self.win_streak = 0
      self.lose_streak += 1
    end
  end
  
  def clear_streak(streak)
    if streak == 'home'
      self.home_win_streak = 0
      self.home_lose_streak = 0
    elsif streak == 'away'
      self.away_win_streak = 0
      self.away_lose_streak = 0
    elsif streak == 'division'
      self.div_win_streak = 0
      self.div_lose_streak = 0
    elsif streak == 'conf'
      self.conf_win_streak = 0
      self.conf_lose_streak = 0
    else
      self.win_streak = 0
      self.lose_streak = 0
    end
  end
end
