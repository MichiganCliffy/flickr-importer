require_relative "./flickr_importer"

FlickRaw.api_key = "53cd1e15db474f964abc3cfc16e0735f"
FlickRaw.shared_secret = "786ddc128885ed49"

task :default do
  importer = FlickrImporter.new
  importer.run()
  puts ''
end

task :test_import do
  importer = FlickrImporter.new
  importer.run({"database_name" => "testing"})
end

task :test_pull_from_flickr do
  importer = FlickrImporter.new()
  albums = importer.pull_from_flickr()
end

task :test_push_to_mongo do
  repo = FlickrSetRepository.new()
  album = repo.get_album("72157602427960981")

  albums = []
  albums << album
  
  importer = FlickrImporter.new({"database_name" => "testing"})
  importer.push_to_mongo(albums)
end
