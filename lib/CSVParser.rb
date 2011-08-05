
class CSVParser
	attr_reader :file, :items

	def initialize(file_name)
		@items = []
		
		parsed = begin
			@file = File.new(file_name)
			
			file_lines = @file.readlines
			
			file_lines.each do |line|
				@items << line.split(/,/)
			end
		rescue ArgumentError => e
			puts "Could not open file " + file_name + ": #{e.message}"
		end		
	end
end
