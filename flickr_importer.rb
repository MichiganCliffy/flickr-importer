require_relative "./flickr_repositories"
require_relative "./mongo_repository"

class FlickrImporter
  GROUP_ID = "31386902@N00"
  GROUP_ALBUM_ID = "Pool"

  # this array should be in the order that you want to display on the site
  PHOTO_SETS = ["72157645299291057", "72157624473398430", "72157621459686057", "72157620904653603", "72157606701085631", "72157602427960981", "72157594373088876", "1157473", "707782", "72157594259055081"]

  def initialize(args = {})
  end

  def pull_from_flickr()
    print 'retrieving albums from flickr'
    STDOUT.flush

    albums = []

    albums << pull_group_pool_from_flickr

    sort_order = 2
    PHOTO_SETS.each do |photoset_id|
      print '.'
      STDOUT.flush
      albums << pull_photoset_from_flickr(photoset_id, sort_order)

      sort_order += 1
    end

    print '.'
    STDOUT.flush
    return albums
  end

  def push_to_mongo(albums, args = {})
    puts 'storing to mongo...'
    repo = MongoRepository.new(args)
    repo.save_albums(albums)
  end

  def run(args = {})
    albums = pull_from_flickr()
    push_to_mongo(albums, args)
  end

  private

  def pull_group_pool_from_flickr()
    repo = FlickrGroupRepository.new()
    output = repo.get_album(GROUP_ID)
    output.id = "Pool"
    output.description = "Shared Group Pool"
    output.title = "Shared Group Pool"
    output.sort_order = 1

    output.photographs.each do |photograph|
      photograph.album_id = "Pool"
    end

    return output
  end

  def pull_photoset_from_flickr(photoset_id, sort_order)
    repo = FlickrSetRepository.new()
    output = repo.get_album(photoset_id)
    output.sort_order = sort_order
    return output
  end
end