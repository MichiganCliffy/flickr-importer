require "json"
require "mongo"
require "date"
require_relative "./mongo_adapters"

class MongoRepository
  attr_accessor :database_host,
                :database_port,
                :database_name,
                :protocol,
                :album_table_name,
                :photograph_table_name

  def initialize(args = {})
    Mongo::Logger.logger.level = Logger::FATAL
    
    # set the defaults
    @database_name = "cliffy"
    @album_table_name = "sets"
    @photograph_table_name = "photographs"
    @protocol = "mongodb"

    if ENV["MONGO_HOST"] != nil && ENV["MONGO_HOST"].length > 0
      @database_host = ENV["MONGO_HOST"]
    end

    if ENV["MONGO_PORT"] != nil && ENV["MONGO_PORT"].length > 0
      @database_port = ENV["MONGO_PORT"]
    end

    if ENV["PROTOCOL"] != nil && ENV["PROTOCOL"].length > 0
      @protocol = ENV["PROTOCOL"]
    end

    parse_args(args)
  end

  def save_albums(albums)
    wrap_mongo_call { |db|
      drop_temp_tables(db)

      adapter = MongoAdapter.new()
      albums.each do |album|
        print "."
        STDOUT.flush
        store_album(db, album, adapter)
        store_photographs(db, album, adapter)
      end

      print "."
      STDOUT.flush
      drop_real_tables(db)
      print "\ndropped old collections"
      STDOUT.flush
      rename_temp_tables(db)
      print "\nrenamed new collections\n"
      STDOUT.flush
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

    if args["protocol"] != nil && args["protocol"].length > 0
      @protocol = args["protocol"]
    end
  end

  def drop_temp_tables(db)
    db[@album_table_name + "_"].drop
    db[@photograph_table_name + "_"].drop
  end

  def store_album(db, album, adapter)
    db[@album_table_name + "_"].insert_one(adapter.album_to_mongo(album))
  end

  def store_photographs(db, album, adapter)
    if album.respond_to?("photographs")
      album.photographs.each do |photograph|
        db[@photograph_table_name + "_"].insert_one(adapter.photograph_to_mongo(photograph))
      end
    end
  end

  def drop_real_tables(db)
    db[@album_table_name].drop
    db[@photograph_table_name].drop
  end

  def rename_temp_tables(db)
    db.use(:admin).command(
      renameCollection: "#{@database_name}.#{@album_table_name}_",
      to: "#{@database_name}.#{@album_table_name}"
    )

    db.use(:admin).command(
      renameCollection: "#{@database_name}.#{@photograph_table_name}_",
      to: "#{@database_name}.#{@photograph_table_name}"
    )

    # db[@album_table_name + "_"].rename(@album_table_name)
    # db[@photograph_table_name + "_"].rename(@photograph_table_name)
  end

  def wrap_mongo_call
    url = @protocol + '://'

    user = ENV["MONGO_USER"]
    if user != nil && user.length > 0
      password = ENV["MONGO_PWD"]
      url += user + ':' + password + '@'
    end

    if @database_host != nil && @database_host.length > 0
      if @database_port != nil && @database_port.length > 0
        if @database_port == '0'
          url += @database_host
        else
          url += @database_host + ':' + @database_port
        end
      else
        url += @database_host + ':27017'
      end
    else
      url += '127.0.0.1:27017'
    end

    url += '/' + @database_name

    db = Mongo::Client.new(url)

    yield db

    db = nil
  end
end