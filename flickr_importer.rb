require "json"
require "mongo"
require "date"
require_relative "./flickr_group_repository"
require_relative "./flickr_set_repository"
require_relative "./mongo_adapter_photograph"
require_relative "./mongo_adapter_photograph_album"

class FlickrImporter
  GROUP_ID = "31386902@N00"
  GROUP_ALBUM_ID = "Pool"
  PHOTO_SETS = ["72157606701085631", "72157602427960981", "72157594373088876", "1157473" , "707782", "72157594259055081", "72157620904653603", "72157621459686057", "72157624473398430"]

  attr_accessor :database_host,
                :database_port,
                :database_name,
                :album_table_name,
                :photograph_table_name

  def initialize(args = {})
    # set the defaults
    @database_name = "cliffy"
    @album_table_name = "sets"
    @photograph_table_name = "photographs"

    parse_args(args)
  end

  def pull_from_flickr()
    print 'retrieving albums from flickr'
    STDOUT.flush

    albums = []

    albums << pull_group_pool_from_flickr

    PHOTO_SETS.each do |photoset_id|
      print '.'
      STDOUT.flush
      albums << pull_photoset_from_flickr(photoset_id)
    end

    print '.'
    STDOUT.flush
    return albums
  end

  def push_to_mongo(albums)
    print 'storing to mongo'
    STDOUT.flush
    wrap_mongo_call { |db|
      print '.'
      STDOUT.flush
      drop_temp_tables(db)

      albums.each do |album|
        print '.'
        STDOUT.flush
        store_album(db, album)

        print '.'
        STDOUT.flush
        store_photographs(db, album)
      end

      print '.'
      STDOUT.flush
      drop_real_tables(db)

      print '.'
      STDOUT.flush
      rename_temp_tables(db)
    }
  end

  def run(args = {})
    parse_args(args)
    albums = pull_from_flickr()
    push_to_mongo(albums)
  end

  private

  def parse_args(args)
    if args["album_table_name"] != nil
      @album_table_name = args["album_table_name"]
    end

    if args["photograph_table_name"] != nil
      @photograph_table_name = args["photograph_table_name"]
    end

    if args["database_name"] != nil
      @database_name = args["database_name"]
    end

    load_mongo_host(args)
    load_mongo_port(args)
  end

  def load_mongo_host(args)
    if ENV["MONGO_HOST"] != nil && ENV["MONGO_HOST"].length > 0
      @database_host = ENV["MONGO_HOST"]
    end

    if args["database_host"] != nil && args["database_host"].length > 0
      @database_host = args["database_host"]
    end
  end

  def load_mongo_port(args)
    if ENV["MONGO_PORT"] != nil && ENV["MONGO_PORT"].length > 0
      @database_port = ENV["MONGO_PORT"]
    end

    if args["database_port"] != nil && args["database_port"].length > 0
      @database_port = args["database_port"]
    end
  end

  def drop_temp_tables(db)
    tables = db.collection_names

    if tables.include? @album_table_name + "_"
      db[@album_table_name + "_"].drop
    end

    if tables.include? @photograph_table_name + "_"
      db[@photograph_table_name + "_"].drop
    end
  end

  def store_album(db, album)
    adapter = MongoAdapterPhotographAlbum.new()
    db[@album_table_name + "_"].insert(adapter.album_to_mongo(album))
  end

  def store_photographs(db, album)
    adapter = MongoAdapterPhotograph.new()
    album.photographs.each do |photograph|
      db[@photograph_table_name + "_"].insert(adapter.photograph_to_mongo(photograph))
    end
  end

  def drop_real_tables(db)
    tables = db.collection_names

    if tables.include? @album_table_name
      db[@album_table_name].drop
    end

    if tables.include? @photograph_table_name
      db[@photograph_table_name].drop
    end
  end

  def rename_temp_tables(db)
    tables = db.collection_names

    if tables.include? @album_table_name + "_"
      db[@album_table_name + "_"].rename(@album_table_name)
    end

    if tables.include? @photograph_table_name + "_"
      db[@photograph_table_name + "_"].rename(@photograph_table_name)
    end
  end

  def pull_group_pool_from_flickr()
    repo = FlickrGroupRepository.new()
    output = repo.get_album(GROUP_ID)
    output.id = "Pool"
    output.description = "Shared Group Pool"
    output.title = "Shared Group Pool"

    output.photographs.each do |photograph|
      photograph.album_id = "Pool"
    end

    return output
  end

  def pull_photoset_from_flickr(photoset_id)
    repo = FlickrSetRepository.new()
    repo.get_album(photoset_id)
  end

  def wrap_mongo_call
    if @database_host != nil && @database_host.length > 0
      if @database_port != nil && @database_port.length > 0
        client = Mongo::MongoClient.new(@database_host, @database_port)
      else
        client = Mongo::MongoClient.new(@database_host)
      end
    else
      client = Mongo::MongoClient.new()
    end

    db = client.db(@database_name)

    user = ENV["MONGO_USER"]
    if user != nil && user.length > 0
      password = ENV["MONGO_PWD"]
      db.authenticate(user, password)
    end

    yield db

    db = nil
    client.close
    client = nil
  end
end