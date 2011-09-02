require 'CSVParser'
require 'String'
require 'DateFormatter'

desc 'A rake task to set the NFL schedule from a specified CSV file
	The format is <game_week>, <game_time>, <away team>, <home team>
	Usage: rake set_schedule [<filename>]'
task :set_schedule, [:filename] => [:environment] do |t, args|
	if args[:filename] =~ /.csv\z/i
		@games = CSVParser.new(args[:filename])
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
	else
		puts "Please submit a valid .CSV file\nUsage: rake set_schedule [<filename>]"
	end	
end

task :count_games_by_team => :environment do
	team = Team.all
	team.each do |t|
		games = Game.count(:conditions => ["hometeam_id = ? or awayteam_id = ?", t.id, t.id])
		puts t.id, games
	end
end