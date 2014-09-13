require_relative "./photograph"
require_relative "./photograph_size"
require_relative "./photograph_uri"

class MongoAdapterPhotograph
	def map_from_source(source)
		photograph = Photograph.new()
		if source != nil
			photograph.date_saved = source["DateSaved"]
			photograph.description = source["Description"]
			photograph.media = source["Media"]
			photograph.photographer = source["Photographer"]
			photograph.photo_id = source["PhotoId"]
			photograph.secret = source["Secret"]
			photograph.album_id = source["SetId"]
			photograph.title = source["Title"]
			photograph.uri_source = source["UriSource"]
			photograph.tags = map_tags(source["Tags"])
			photograph.uri_sizes = map_uri_sizes(source["UriSizes"])
		end
		return photograph
	end

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
	
	private

	def map_uri_sizes(source)
		output = []
		if source != nil
			sizes = source.to_a
			sizes.each do |size|
				uriSize = PhotographUri.new()
				uriSize.uri = size["Uri"]
				uriSize.set_size(size["Size"])
				output << uriSize
			end
		end
		return output
	end
	
	def map_tags(source)
		output = []
		if source != nil
			tags = source.to_a
			tags.each do |tag|
				output << tag
			end
		end
		return output
	end
end