require_relative "./photograph_size"

class PhotographUri
	attr_accessor :size
	attr_accessor :uri
    
	def initialize()
		@size = PhotographSize::UNDEFINED
	end

	def set_size(sizeId)
		case sizeId
			when 0
				@size = PhotographSize::THUMBNAIL

			when 1
				@size = PhotographSize::SMALL
    		
			when 2
				@size = PhotographSize::MEDIUM
    		
			when 3
				@size = PhotographSize::LARGE
    		
			when 4
				@size = PhotographSize::ORIGINAL
		end
	end

	def get_size_id()
		case @size
			when PhotographSize::THUMBNAIL
				return 0

			when PhotographSize::SMALL
				return 1
    		
			when PhotographSize::MEDIUM
				return 2
    		
			when PhotographSize::LARGE
				return 3
    		
			when PhotographSize::ORIGINAL
				return 4
		end

		return nil
	end
end