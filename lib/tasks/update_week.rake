desc 'a rake task to update the scores of the game'
task :update_scores => :environment do
  myArray = Feed.parse_feed("http://64.246.64.135/aspdata/clients/sportsnetwork/NFLrssscores.aspx", /, /)

  finalArray = Scores.build_array(myArray)

  if finalArray
    @tempfinalArray = Array.new
    finalArray.each { |item| @tempfinalArray << item }

    Scores.set(finalArray)
  end
end

desc 'a rake task to update the results of the game and the users for the latest week'
task :update_results => :update_scores do
  thisWeek = CutoffTime.get_this_week
  
  weekObj = Week.find(thisWeek)
  
  games = Game.find(:all, :conditions => ["week = ?", thisWeek], :order => 'game_time, id')
  usersPicks = Pick.find(:all, :conditions => ["week = ?", thisWeek], :select => 'distinct user_id')

  count = 1

  for game in games
    game.update_winner

    Pick.update_points(game.id)
        
    last = game
        
    count += 1
  end
  
  for userPicks in usersPicks
    wup = WeeklyUserPoint.find(:first, :conditions => ["week = ? and user_id = ?", thisWeek, userPicks.user_id])
    if !wup
      wup = WeeklyUserPoint.new(:week => thisWeek, :user_id => userPicks.user_id, :points => 0)
    end

    wup.update_user_week(userPicks)
  end

  all_users = User.find(:all)
  for user in all_users
    tup = TotalUserPoint.find(:first, :conditions => ["user_id = ?", user.id])
    if !tup
      tup = TotalUserPoint.new(:user_id => user.id, :points => 0)
      tup.save
    end
    
    tup.update_user_season(thisWeek)
  end

  weekObj.update_status(last.game_time)
end

task :update_nfl_standings => :environment do
	weeks = Week.find(:all)
	for week in weeks
		if week.submitted == 0 and week.played == 1
			games = Game.find(:all, :conditions => ["week = ?", week.week], :order => 'game_time, id')
			tie = false

			for game in games
				hometeam = Team.find(game.hometeam_id)
				awayteam = Team.find(game.awayteam_id)

				Team.update_points(hometeam, awayteam, game)

				winner = game.find_winner(hometeam, awayteam)
				if winner
					winner.update_wins
					winner.update_streak('overall', 'win')

					if winner.id == game.hometeam_id
						winner.update_home_wins
						winner.update_streak('home', 'win')
					else
						winner.update_away_wins
						winner.update_streak('away', 'win')
					end
				end

				loser = game.find_loser(hometeam, awayteam)
				if loser
					loser.update_losses
					loser.update_streak('overall', 'lose')

					if loser.id == game.hometeam_id
						loser.update_home_losses
						loser.update_streak('home', 'lose')
					else
						loser.update_away_losses
						loser.update_streak('away', 'lose')
					end
				end

				if !winner and !loser
					Team.update_ties(hometeam, awayteam, game)

					tie = true
				else
					if winner.conf_id == loser.conf_id
						winner.update_conf_wins
						winner.update_streak('conf', 'win')

						loser.update_conf_losses
						loser.update_streak('conf', 'lose')

						if winner.division_id == loser.division_id
							winner.update_division_wins
							winner.update_streak('division', 'win')

							loser.update_division_losses
							loser.update_streak('division', 'lose')
						end
					end

					tie = false
				end

				hometeam.save
				awayteam.save
			end

			if !games.empty? and ((winner and loser) or tie)
				week.submit
			end
		end
	end
end