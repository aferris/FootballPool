require 'CSVParser'
require 'String'
require 'DateFormatter'

desc 'A rake task to send an email to the users indicating the winner of the current week'
task :set_schedule => [:environment] do
	@games = CSVParser.new("2011sched.csv")
	@games.items.each do |game|
		game_week = game[0].strip_or_self!
		game_time = DateFormatter.new(game[1].strip_or_self!)
		away_team = Team.find_by_abbreviation(game[2].strip_or_self!)
		home_team = Team.find_by_abbreviation(game[3].strip_or_self!)
		
		new_game = Game.new(:week => game_week, :hometeam_id => home_team.id, :awayteam_id => away_team.id, :game_time => game_time.mysql)
		if new_game.nil?
			puts "not saved"
		else
			if !new_game.save
				puts "not saved"
			end
		end
	end
end

task :count_games_by_team => :environment do
	team = Team.all
	team.each do |t|
		games = Game.count(:conditions => ["hometeam_id = ? or awayteam_id = ?", t.id, t.id])
		puts t.id, games
	end
end