require 'active_record'

database_config = YAML.load_file '../config/database.yml'
ActiveRecord::Base.establish_connection(database_config[ ENV['env'] || "development"])