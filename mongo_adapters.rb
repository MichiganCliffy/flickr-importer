require_relative "./models"

class MongoAdapter
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

	def album_to_mongo(album)
		if album.is_a?(Hash)
			return hash_to_mongo_album(album)
		end

		if album.is_a?(PhotographAlbum)
			return album_object_to_mongo_album(album)
		end

		return nil
	end

	private

	def hash_to_mongo_album(hash)
		output = {:_id => nil, :Title => nil, :Description => nil, :SortOrder => 9999}

		hash.keys.each do |key|

			case key.downcase
				when "id"
					output[:_id] = hash[key]

				when "title"
					output[:Title] = hash[key]
					output[:UriId] = hash[key].sub(' ', '-').downcase

				when "description"
					output[:Description] = hash[key]

				when "sort_order"
					output[:SortOrder] = hash[key].to_i

				when "type"
					output[:Type] = hash[key]

				else
					output[eval(":#{key.capitalize}")] = hash[key]

			end
		end

		pages = []
		if hash["pages"] != nil
			hash["pages"].each do |page|
				pages << {:Type => page.type, :Title => page.title, :Value => page.value}
			end
		end
		output[:Pages] = pages

		return output
	end

	def album_object_to_mongo_album(album)
		tags = []
		album.tags.each do |tag|
			tags << {:Tag => tag.tag, :Count => tag.count}
		end

		pages = []
		album.pages.each do |page|
			pages << {:Type => page.type, :Title => page.title, :Value => page.value}
		end

		output = {
			:_id => album.id,
			:UriId => album.uri_id.sub(' ', '-').downcase,
			:Type => album.type,
			:Title => album.title,
			:Description => album.description,
			:SortOrder => album.sort_order,
			:Total => album.total,
			:DefaultPhotoId => album.default_photograph_id,
			:Tags => tags,
			:Pages => pages
		}

		return output
	end
end