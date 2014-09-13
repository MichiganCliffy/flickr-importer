require "flickraw"
require_relative "./photograph_album"
require_relative "./flickr_adapter_photograph"
require_relative "./flickr_adapter_photograph_album"

include FlickRaw

class FlickrGroupRepository
  attr_accessor :max_number_of_photographs

  def initialize(args = {})
    @max_number_of_photographs = 75

    if args["max_number_of_photographs"] != nil
      @max_number_of_photographs = args["max_number_of_photographs"]
    end
  end

  def get_album(album_id)
    output = PhotographAlbum.new
    output.id = album_id

    pages = 2
    page = 1

    until page > pages do
      print "."
      STDOUT.flush
      pool = flickr.groups.pools.getPhotos :group_id => album_id,
                                           :extras => "tags,description,media,url_sq,url_t,url_s,url_m,url_o",
                                           :page => page

      if pool != nil
        pool.each do |item|
          print "."
          STDOUT.flush
          output.add(map_to_photograph(album_id, item))
        end

        if pool.pages.to_i != pages
          pages = pool.pages.to_i
        end
      end

      page += 1
    end

    return output
  end

  def get_photographs(album_id, args = {})
    page = 1
    if args["page"] != nil
      page = args["page"].to_i
    end

    tags = ""
    if args["tags"] != nil && args["tags"].count > 0
      tags = args["tags"].join(" ")
    end

    output = []
    pool = flickr.groups.pools.getPhotos :group_id => album_id,
                                         :extras => "tags,description,media,url_sq,url_t,url_s,url_m,url_o",
                                         :page => page,
                                         :per_page => @max_number_of_photographs,
                                         :tags => tags
    if pool != nil
      pool.each do |item|
        output << map_to_photograph(album_id, item)
      end
    end

    return output
  end

  private

  def map_to_photograph(album_id, photograph)
    adapter = FlickrAdapterPhotograph.new()
    adapter.map_from_source(album_id, photograph)
  end

end