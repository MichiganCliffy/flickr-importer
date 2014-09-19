require 'yaml'
require_relative "./flickr_importer"

FlickRaw.api_key = "53cd1e15db474f964abc3cfc16e0735f"
FlickRaw.shared_secret = "786ddc128885ed49"

task :default do
  importer = FlickrImporter.new
  importer.run({"config_file" => "cliffordcorner.yml"})
  puts ''
end

task :test_import do
  importer = FlickrImporter.new
  importer.run({"database_name" => "testing", "config_file" => "cliffordcorner.yml"})
end

task :test_pull_from_flickr do
  config = YAML.load_file('cliffordcorner.yml')
  importer = FlickrImporter.new()
  albums = importer.pull_from_flickr(config)
end

task :test_push_to_mongo do
  repo = FlickrSetRepository.new()
  album = repo.get_album("72157602427960981")

  albums = []
  albums << album
  
  importer = FlickrImporter.new({"database_name" => "testing"})
  importer.push_to_mongo(albums)
end

task :test_ymal_read do
  config = YAML.load_file('cliffordcorner.yml')
  puts config["albums"][2]
end

task :test_hash_mapping do
  config = YAML.load_file('cliffordcorner.yml')
  adapter = MongoAdapter.new()
  puts adapter.album_to_mongo(config["albums"][10])
end