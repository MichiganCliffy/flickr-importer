require_relative "./photograph_album"

class MongoAdapterPhotographAlbum
	attr_accessor :album
	
	def initialize()
		@default_photo_id = nil
		@album = nil
	end

	def map_from_source(source)
		@album = PhotographAlbum.new()
		if source != nil
			album.id = source["_id"]
			album.total = source["Total"]
			album.title = source["Title"]
			album.description = source["Description"]
			album.default_photograph_id = source["DefaultPhotoId"]
		end
	end

	def album_to_mongo(album)
		tags = []
		album.tags.each do |tag|
			tags << {:Tag => tag.tag, :Count => tag.count}
		end

		output = {
			:_id => album.id,
			:Title => album.title,
			:Description => album.description,
			:Total => album.total,
			:DefaultPhotoId => album.default_photograph_id,
			:Tags => tags
		}

		return output
	end
	
	def add_photographs(source)
		if source.respond_to?("each")
			source.each do |item|
				add_photograph(item)
			end
		end
	end
	
	def add_photograph(source)
		if source.photo_id == @album.default_photograph_id
			@album.default_photograph = source
		end
		
		@album.add(source)
	end
end