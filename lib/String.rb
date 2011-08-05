class String
	def strip_or_self!
		strip! || self
	end
end