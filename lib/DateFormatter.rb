class DateFormatter
	attr_reader :date, :mysql
	
	def initialize(date)
		@date = date

		parsed = self.date.split(/-|\/|\s/)

		@mysql = parsed[2] + "-" + parsed[0] + "-" + parsed[1] + " " + parsed[3]
	end
end
