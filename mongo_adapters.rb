class MongoAdapterPhotograph
	def photograph_to_mongo(photograph)
		sizes = []
		photograph.uri_sizes.each do |uri|
			sizes << {:Size => uri.get_size_id(), :Uri => uri.uri}
		end

		output = {
			:DateSaved => photograph.date_saved,
			:Description => photograph.description,
			:Media => photograph.media,
			:Photographer => photograph.photographer,
			:PhotoId => photograph.photo_id,
			:Secret => photograph.secret,
			:SetId => photograph.album_id,
			:Title => photograph.title,
			:UriSource => photograph.uri_source,
			:Tags => photograph.tags,
			:UriSizes => sizes
		}

		return output
	end
end

class MongoAdapterPhotographAlbum
	def album_to_mongo(album)
		tags = []
		album.tags.each do |tag|
			tags << {:Tag => tag.tag, :Count => tag.count}
		end

		output = {
			:_id => album.id,
			:Title => album.title,
			:Description => album.description,
			:SortOrder => album.sort_order,
			:Total => album.total,
			:DefaultPhotoId => album.default_photograph_id,
			:Tags => tags
		}

		return output
	end
end