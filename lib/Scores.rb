class Scores
  def self.build_array (myArray)
    if !myArray.empty?
      myNameArray = Array.new
      myScoreArray = Array.new
      myArray.each {|team|
        if !(team.to_s.include? " at ")
          myNameArray += team.split(/[0-9]{1,2}/)
          myScoreArray += team.split(/[A-Za-z.]* [A-Za-z]*/)
        end
        }

      finalArray = Array.new

      while !myNameArray.empty?
        name = myNameArray.pop
  
        begin
          score = myScoreArray.pop
        end while score == "" 

        finalArray.push(name, score)
      end
    end
  
    return finalArray
  end
  
  def self.set(finalArray)
    thisWeek = CutoffTime.get_this_week

    games = Game.find(:all, :conditions => ["week = ?", thisWeek])

    output = ""

    while !finalArray.empty?
      winner_score = finalArray.pop
      winner_team_name = finalArray.pop

      loser_score = finalArray.pop
      loser_team_name = finalArray.pop

      winner_id = Team.find(:first, :conditions => ["name = ?", winner_team_name]).id
      for game in games
        # the winner is home or away--this covers ties, too
        if game.hometeam_id == winner_id
          game.update_score(winner_score, loser_score)
          break
		elsif game.awayteam_id == winner_id # winner is away
          game.update_score(loser_score, winner_score)
          break
        end
      end
    end
    
    return output
  end
end