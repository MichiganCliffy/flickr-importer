require "json"
require "mongo"
require "date"
require_relative "./mongo_adapters"

class MongoRepository
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

    if ENV["MONGO_HOST"] != nil && ENV["MONGO_HOST"].length > 0
      @database_host = ENV["MONGO_HOST"]
    end

    if ENV["MONGO_PORT"] != nil && ENV["MONGO_PORT"].length > 0
      @database_port = ENV["MONGO_PORT"]
    end

    parse_args(args)
  end

  def save_albums(albums)
    wrap_mongo_call { |db|
      drop_temp_tables(db)

      albums.each do |album|
        store_album(db, album)
        store_photographs(db, album)
      end

      drop_real_tables(db)
      rename_temp_tables(db)
    }
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

    if args["database_host"] != nil && args["database_host"].length > 0
      @database_host = args["database_host"]
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