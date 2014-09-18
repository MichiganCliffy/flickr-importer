require "date"
require "time"
require_relative "./models"

class FlickrAdapterPhotograph
  def map_from_source(album_id, source, photographer = "")
    photograph = Photograph.new()
    if source != nil
      
      if source["dateuploaded"] != nil
        photograph.date_saved = Time.strptime(source["dateuploaded"], "%s")
      end
      
      if source["dateupload"] != nil
        photograph.date_saved = Time.strptime(source["dateupload"], "%s")
      end

      if source["dateadded"] != nil
        photograph.date_saved = Time.strptime(source["dateadded"], "%s")
      end

      if source["description"] != nil
        photograph.description = source["description"]
      end
      
      photograph.media = source["media"]

      if photographer != nil && photographer.length > 0
        photograph.photographer = photographer
      else
        if source["ownername"] != nil && source["ownername"].length > 0
          photograph.photographer = source["ownername"]
        else
          if source["owner"] != nil && source["owner"]["username"].length > 0
            photograph.photographer = source["owner"]["username"]
          end
        end
      end

      photograph.photo_id = source["id"]
      photograph.secret = source["secret"]
      photograph.album_id = album_id
      photograph.title = source["title"]
      photograph.uri_source = "https://www.flickr.com/photos/#{photograph.photographer.downcase}/#{photograph.photo_id}"
      photograph.tags = map_tags(source["tags"])
      photograph.uri_sizes = []

      if source["url_sq"] != nil
        photograph.uri_sizes << create_uri_size(source["url_sq"], PhotographSize::THUMBNAIL)
      end

      if source["url_s"] != nil
        photograph.uri_sizes << create_uri_size(source["url_s"], PhotographSize::SMALL)
      end

      if source["url_m"] != nil
        photograph.uri_sizes << create_uri_size(source["url_m"], PhotographSize::MEDIUM)
      end

      if source["url_o"] != nil
        photograph.uri_sizes << create_uri_size(source["url_o"], PhotographSize::ORIGINAL)
      end

    end
    return photograph
  end

  def create_uri_size(uri, size)
    thumbnail = PhotographUri.new()
    thumbnail.uri = uri
    thumbnail.size = size
    return thumbnail
  end

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
    if source != nil
      tags = nil
      if source.respond_to?("each")
        return map_tags_from_response source
      else
        return map_tags_from_string source
      end
    end
    return []
  end

  private

  def map_tags_from_response(source)
    output = []
    if source != nil
      source.each do |tag|
        output << tag["raw"]
      end
    end
    return output
  end

  def map_tags_from_string(source)
    output = []
    if source != nil
      tags = source.split(' ')
      tags.each do |tag|
        output << tag
      end
    end
    return output
  end
end