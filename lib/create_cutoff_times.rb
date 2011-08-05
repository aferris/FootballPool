# encoding: utf-8

require 'bundler'
require 'active_record'
require 'yaml'

Bundler.require(:default)

unless ARGV.length == 1
	puts "Need an database configuration input file."
	puts "Usage: ruby create_cutoff_times <YML input file>"
	exit
end

db_file = File.open(ARGV[0])
db_config = YAML::load(db_file)

ActiveRecord::Base.establish_connection(db_config)

#ActiveRecord::Base.logger = Logger.new(STDERR)

class Week < ActiveRecord::Base
end

class CutoffTime < ActiveRecord::Base
	validates :week, :uniqueness => true
end

class Game < ActiveRecord::Base
	def self.earliest(week)
		where(:week => week).minimum(:game_time)
	end
end

# make a cutoff time for each week
weeks = Week.all

count = 0
weeks.each do |week|
	# find the earliest game of the week
	earliest = Game.earliest(week.id)
	
	# make the cutoff time for that week the time of the earliest game
	cutoff = CutoffTime.new(:cutoff_time => earliest, :week => week.id)
	if cutoff.save
		count += 1
	end
end

puts count.to_s + " cutoff times saved."