module PhotographSize
	UNDEFINED = -1
	THUMBNAIL = 0
	SMALL = 1
	MEDIUM = 2
	LARGE = 3
	ORIGINAL = 4
end

class Photograph
	attr_accessor	:photo_id,
								:secret,
								:title,
								:description,
								:media,
								:date_saved,
								:photographer,
								:uri_source,
								:uri_sizes,
								:tags,
								:album_id
	def <=>(other)
		other.date_saved <=> date_saved
	end
end

class PhotographAlbumTag
	include Comparable	

	attr_accessor	:tag,
								:count

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

class PhotographAlbumPage
	attr_accessor	:type,
								:title,
								:value
end

class PhotographAlbum
	attr_accessor :id,
								:uri_id,
								:type,
								:title,
								:description,
								:sort_order,
								:default_photograph_id,
								:total,
								:tags,
								:photographs,
								:pages
    
	def initialize()
		@title = ""
		@uri_id = ""
		@description = ""
		@total = 0
		@sort_order = 9999
		@tags = []
		@photographs = []
		@pages = []
	end

	def add(photo)
		add_photo_tags photo
		@photographs << photo
	end

	def add_photo_tags(photo)
		if photo.tags.respond_to?("each")
			photo.tags.each do |tag|
				item = @tags.find(ifnone = nil) { |i| i.tag == tag }
				if item.nil?
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
		tags.each do |tag|
			@tags << tag
		end
	end

end

class PhotographUri
	attr_accessor	:size,
								:uri
    
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