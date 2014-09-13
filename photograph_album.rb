require_relative "./photograph_album_tag"

class PhotographAlbum
	attr_accessor :id,
								:title,
								:description,
								:default_photograph,
								:default_photograph_id,
								:total,
								:tags,
								:photographs
    
	def initialize()
		@title = ""
		@description = ""
		@defaultPhotograph = nil
		@total = 0
		@tags = []
		@photographs = []
	end

	def add(photo)
		add_photo_tags photo
		@photographs << photo
	end

	def add_photo_tags(photo)
		if photo.tags.respond_to?("each")
			photo.tags.each do |tag|
				item = @tags.find(ifnone = nil) { |i| i.tag == tag }
				if item == nil
					newItem = PhotographAlbumTag.new(tag)
					@tags << newItem
				else
					item.count = item.count + 1
				end
			end
		end
	end

	def add_all(photos)
		if photos.respond_to?("each")
			photos.each do |photo|
				add_photo_tags(photo)
			end
			@photographs.concat(photos)
		end
	end

	def add_tags(tags)
		if tags.respond_to?("each")
			tags.each do |tag|
				@tags << tag
			end
		end
	end

end