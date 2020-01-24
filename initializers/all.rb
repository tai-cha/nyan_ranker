require 'twitter'
require 'dotenv'
require 'active_record'
require 'pry'
require_relative '../app/models/tweet'
require_relative '../app/modules/tweet_time'
require_relative '../initializers/database'

Dotenv.load '../.env' unless ENV['env'] == 'production'