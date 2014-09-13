require "flickraw"
require_relative "./flickr_adapter_photograph"
require_relative "./flickr_adapter_photograph_album"

include FlickRaw

class FlickrSetRepository
  attr_accessor :max_number_of_photographs

  def initialize(args = {})
    @max_number_of_photographs = 75

    if args["max_number_of_photographs"] != nil
      @max_number_of_photographs = args["max_number_of_photographs"]
    end
  end

  def get_album(album_id)
    output = nil

    album = flickr.photosets.getInfo :photoset_id => album_id
    if album != nil
      adapter = FlickrAdapterPhotographAlbum.new()
      adapter.map_from_source(album)
      output = adapter.album

      page = 1
      pages = 2
      until page > pages do
        print "."
        STDOUT.flush
        pool = flickr.photosets.getPhotos :photoset_id => album_id,
                                          :extras => "tags,description,media,url_sq,url_t,url_s,url_m,url_o",
                                          :page => page

        if pool != nil
          pool.photo.each do |item|
            output.add(map_to_photograph(album_id, item, pool.ownername))
          end

          if pool.pages.to_i != pages
            pages = pool.pages.to_i
          end
        end

        page += 1
      end
    end

    return output;
  end

  def get_photographs(album_id, args = {})
    page = 1
    if args["page"] != nil
      page = args["page"].to_i
    end

    pool = flickr.photosets.getPhotos :photoset_id => album_id,
                                      :extras => "tags,description,media,url_sq,url_t,url_s,url_m,url_o",
                                      :page => page,
                                      :per_page => @max_number_of_photographs

    output = []
    if pool != nil && pool.photo != nil
      pool.photo.each do |item|
        output << map_to_photograph(album_id, item, pool.ownername)
      end
    end
    return output
  end

  private

  def map_to_photograph(album_id, photograph, ownername)
    adapter = FlickrAdapterPhotograph.new()
    photograph = adapter.map_from_source(album_id, photograph)
    photograph.photographer = ownername
    return photograph
  end
end