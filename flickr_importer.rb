require 'yaml'

require_relative "./flickr_repositories"
require_relative "./mongo_repository"

class FlickrImporter
  def initialize(args = {})
  end

  def pull_from_flickr(config)
    print 'retrieving albums from flickr'
    STDOUT.flush

    albums = []

    config["albums"].each do |album|
      print '.'
      STDOUT.flush

      case album["type"]
        when "pool"
          albums << pull_group_pool_from_flickr(album)

        when "album"
          albums << pull_photoset_from_flickr(album)

        else
          albums << album
      end
    end

    puts '.'
    return albums
  end

  def push_to_mongo(albums, args = {})
    print 'storing to mongo...'
    STDOUT.flush

    repo = MongoRepository.new(args)
    repo.save_albums(albums)

    puts '.'
  end

  def run(args = {})
    config = read_config_file(args)
    albums = pull_from_flickr(config)
    push_to_mongo(albums, args)
  end

  def read_config_file(args = {})
    return YAML.load_file(args["config_file"])
  end

  private

  def pull_group_pool_from_flickr(album)
    repo = FlickrGroupRepository.new()
    output = repo.get_album(album["id"])
    output.id = "Pool"
    output.uri_id = "Pool"
    output.type = album["type"]
    output.description = album["description"]
    output.title = album["title"]
    output.sort_order = album["sort_order"].to_i
    output.pages = to_pages(album)

    output.photographs.each do |photograph|
      photograph.album_id = "Pool"
    end

    return output
  end

  def pull_photoset_from_flickr(album)
    repo = FlickrSetRepository.new()
    output = repo.get_album(album["id"])
    output.uri_id = album["title"]
    output.type = album["type"]

    if output.description == nil || output.description.length == 0
      output.description = album["description"]
    end

    if output.title == nil || output.title.length == 0
      output.title = album["title"]
    end

    output.sort_order = album["sort_order"].to_i
    output.pages = to_pages(album)
    return output
  end

  def to_pages(album)
    output = []

    if album["pages"] != nil
      album["pages"].each do |page|
        album_page = PhotographAlbumPage.new()
        album_page.type = page["type"]
        album_page.title = page["title"]
        album_page.value = get_page_value(page)

        output << album_page
      end
    end

    return output
  end

  def get_page_value(page)
    output = page["value"]
    
    if page["type"] == "html"
      file = File.open(page["value"], "rb")
      output = file.read
      file.close
    end

    output
  end
end