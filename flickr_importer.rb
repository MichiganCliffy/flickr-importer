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
    puts 'storing to mongo...'
    repo = MongoRepository.new(args)
    repo.save_albums(albums)
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
    output.description = album["description"]
    output.title = album["title"]
    output.sort_order = album["sort_order"].to_i

    output.photographs.each do |photograph|
      photograph.album_id = "Pool"
    end

    return output
  end

  def pull_photoset_from_flickr(album)
    repo = FlickrSetRepository.new()
    output = repo.get_album(album["id"])
    output.description = album["description"]
    output.title = album["title"]
    output.sort_order = album["sort_order"].to_i
    return output
  end
end