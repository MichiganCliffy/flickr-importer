require_relative "./photograph_album"

class FlickrAdapterPhotographAlbum
  attr_accessor :album
  
  def initialize()
    @default_photo_id = nil
    @album = nil
  end

  def map_from_source(source)
    @album = PhotographAlbum.new()
    if source != nil
      album.id = source["id"]
      album.total = source["photos"]
      album.title = source["title"]
      album.description = source["description"]
      album.default_photograph_id = source["primary"]
    end
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