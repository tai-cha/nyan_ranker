require 'bundler/setup'
require 'active_record'
require 'erb'

include ActiveRecord::Tasks

root_dir = File.dirname(__FILE__)

config_database_yml_file = File.join(root_dir, 'config', 'database.yml')
config_database_yml = YAML::load(ERB.new(File.read(config_database_yml_file)).result)

DatabaseTasks.env = ENV['env'] || 'development'
DatabaseTasks.db_dir = File.join(root_dir, 'db')
DatabaseTasks.database_configuration = config_database_yml
DatabaseTasks.migrations_paths = File.join(root_dir, 'db', 'migrate')

task :environment do
  ActiveRecord::Base.configurations = config_database_yml
  ActiveRecord::Base.establish_connection :development
end

load 'active_record/railties/databases.rake'

namespace :g do
  desc "Generate migration"
  task :migration do
    name = ARGV[1] || raise("Specify name: rake g:migration your_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
class #{migration_class} < ActiveRecord::Migration[5.2]
  def change
  end
end
      EOF
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end