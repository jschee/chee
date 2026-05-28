# frozen_string_literal: true

require "active_record"
require "erb"
require "yaml"

Dotenv.load if defined?(Dotenv)

env = ENV.fetch("RACK_ENV", "development")
config_path = File.expand_path("database.yml", __dir__)
config = YAML.safe_load(ERB.new(File.read(config_path)).result, aliases: true)

ActiveRecord::Base.establish_connection(config.fetch(env))
