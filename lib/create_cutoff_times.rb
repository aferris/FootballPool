require File.dirname(__FILE__) + '/CSVParser'
require 'bundler'
require 'active_record'
require 'yaml'

Bundler.require(:default, :development)

#dbconfig = YAML::load(File.open(File.dirname(__FILE__) + '/../config/database.yml'))
ActiveRecord::Base.establish_connection(:adapter => :mysql2,
  :database => "pool3",
  :username => "root",
  :password => "",
  :host => "localhost",
  :pool => 5,
  :timeout => 5000,
  )

ActiveRecord::Base.logger = Logger.new(STDERR)

class Week < ActiveRecord::Base
end

class CutoffTime < ActiveRecord::Base
end

class Game < ActiveRecord::Base
	def self.earliest(week)
		where(:week => week).minimum(:game_time)
	end
end

# make a cutoff time for each week
weeks = Week.all

weeks.each do |week|
	# find the earliest game of the week
	earliest = Game.earliest(week)
	
	# make the cutoff time for that week the time of the earliest game
	cutoff = CutoffTime.new(:cutoff_time => earliest, :week => week)
	cutoff.save
end