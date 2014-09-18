require "flickraw"
require_relative "./flickr_adapters"

include FlickRaw

class FlickrBaseRepository
  def to_photograph(album_id, photograph, ownername = "")
    adapter = FlickrAdapterPhotograph.new()
    adapter.map_from_source(album_id, photograph, ownername)
  end
end

class FlickrSetRepository < FlickrBaseRepository
  def get_album(album_id)
    output = PhotographAlbum.new()

    album = flickr.photosets.getInfo :photoset_id => album_id
    if album != nil
      output.id = album["id"]
      output.total = album["photos"]
      output.title = album["title"]
      output.description = album["description"]
      output.default_photograph_id = album["primary"]

      page = 1
      pages = 2
      until page > pages do
        print "."
        STDOUT.flush
        pool = flickr.photosets.getPhotos :photoset_id => album_id,
                                          :extras => "tags,description,date_upload,media,url_sq,url_t,url_s,url_m,url_o",
                                          :page => page

        if pool != nil
          pool.photo.each do |item|
            output.add(to_photograph(album_id, item, pool.ownername))
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
end

class FlickrGroupRepository < FlickrBaseRepository
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
          output.add(to_photograph(album_id, item, ""))
        end

        if pool.pages.to_i != pages
          pages = pool.pages.to_i
        end

        if output.total != pool.total
          output.total = pool.total
        end
      end

      page += 1
    end

    return output
  end
end