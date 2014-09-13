class PhotographAlbumTag
	include Comparable	

	attr_accessor :tag
	attr_accessor :count

	def initialize(tag = nil)
		@tag = tag
		@count = 1
	end

	def <=>(other)
		if other.count == count
			tag <=> other.tag
		else
			other.count <=> count
		end
	end
end