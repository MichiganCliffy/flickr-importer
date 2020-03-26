require 'yaml'
require_relative "./flickr_importer"

task :default do
  if ENV["FLICKR_API_KEY"] != nil && ENV["FLICKR_API_KEY"].length > 0
    FlickRaw.api_key = ENV["FLICKR_API_KEY"]
  end

  if ENV["FLICKR_SHARED_SECRET"] != nil && ENV["FLICKR_SHARED_SECRET"].length > 0
    FlickRaw.shared_secret = ENV["FLICKR_SHARED_SECRET"]
  end

  importer = FlickrImporter.new
  importer.run({"config_file" => "cliffordcorner.yml"})
  puts ''
end

task :stage do
  if ENV["FLICKR_API_KEY"] != nil && ENV["FLICKR_API_KEY"].length > 0
    FlickRaw.api_key = ENV["FLICKR_API_KEY"]
  end

  if ENV["FLICKR_SHARED_SECRET"] != nil && ENV["FLICKR_SHARED_SECRET"].length > 0
    FlickRaw.shared_secret = ENV["FLICKR_SHARED_SECRET"]
  end

  importer = FlickrImporter.new
  importer.run({"database_name" => "testing", "config_file" => "cliffordcorner.yml"})
end

task :test_config_read do
  importer = FlickrImporter.new
  config = importer.read_config_file({"config_file" => "cliffordcorner.yml"})
  puts config.inspect
end

task :test_pull_from_flickr do
  if ENV["FLICKR_API_KEY"] != nil && ENV["FLICKR_API_KEY"].length > 0
    FlickRaw.api_key = ENV["FLICKR_API_KEY"]
  end

  if ENV["FLICKR_SHARED_SECRET"] != nil && ENV["FLICKR_SHARED_SECRET"].length > 0
    FlickRaw.shared_secret = ENV["FLICKR_SHARED_SECRET"]
  end

  importer = FlickrImporter.new
  config = importer.read_config_file({"config_file" => "cliffordcorner.yml"})
  albums = importer.pull_from_flickr(config)
  puts albums.inspect
end

task :test_push_to_mongo do
  if ENV["FLICKR_API_KEY"] != nil && ENV["FLICKR_API_KEY"].length > 0
    FlickRaw.api_key = ENV["FLICKR_API_KEY"]
  end

  if ENV["FLICKR_SHARED_SECRET"] != nil && ENV["FLICKR_SHARED_SECRET"].length > 0
    FlickRaw.shared_secret = ENV["FLICKR_SHARED_SECRET"]
  end

  repo = FlickrSetRepository.new()
  album = repo.get_album("72157602427960981")

  albums = []
  albums << album
  
  importer = FlickrImporter.new({"database_name" => "testing"})
  importer.push_to_mongo(albums, {"database_name" => "testing"})
end

task :test_hash_mapping do
  config = YAML.load_file('cliffordcorner.yml')
  adapter = MongoAdapter.new()
  puts adapter.album_to_mongo(config["albums"][10])
end
