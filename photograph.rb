class Photograph
	attr_accessor :photo_id
	attr_accessor :secret
	attr_accessor :title
	attr_accessor :description
	attr_accessor :media
	attr_accessor :date_saved
	attr_accessor :photographer
	attr_accessor :uri_source
	attr_accessor :uri_sizes
	attr_accessor :tags
	attr_accessor :album_id

	def initialize()
		@tags = []
		@uriSizes = []
	end

	def <=>(other)
		other.date_saved <=> date_saved
	end
end
