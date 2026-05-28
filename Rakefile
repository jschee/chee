# frozen_string_literal: true

require "active_record"
require "active_record/tasks/database_tasks"
require "yaml"
require "erb"

APP_ENV = ENV.fetch("APP_ENV", ENV.fetch("RACK_ENV", "development"))

database_config = YAML.safe_load(
  ERB.new(File.read("config/database.yml")).result,
  aliases: true
)

ActiveRecord::Base.configurations = database_config
ActiveRecord::Base.establish_connection(APP_ENV.to_sym)

ActiveRecord::Tasks::DatabaseTasks.root = Dir.pwd
ActiveRecord::Tasks::DatabaseTasks.env = APP_ENV
ActiveRecord::Tasks::DatabaseTasks.database_configuration = database_config
ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ["db/migrate"]
ActiveRecord::Tasks::DatabaseTasks.db_dir = "db"

namespace :db do
  task :create do
    ActiveRecord::Tasks::DatabaseTasks.create_current
  end

  task :drop do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
  end

  task :migrate do
    ActiveRecord::Tasks::DatabaseTasks.migrate
  end

  task :rollback do
    ActiveRecord::Tasks::DatabaseTasks.rollback
  end

  task :seed do
    require_relative "config/application"
    load "db/seeds.rb"
  end

  task setup: [:create, :migrate]
  task reset: [:drop, :create, :migrate]
end

namespace :template do
  task :import, [:path] do |_task, args|
    require_relative "scripts/import_template"

    path = args[:path]
    abort "Usage: bundle exec rake 'template:import[views/templates/article.html]'" unless path

    ImportTemplate.call(path)
  end

  task :import_all do
    require_relative "scripts/import_template"

    Dir.glob("views/templates/*.html").sort.each do |path|
      ImportTemplate.call(path)
    end
  end
end

namespace :article do
  task :import, [:path] do |_task, args|
    require_relative "scripts/create_article"

    path = args[:path]
    abort "Usage: bundle exec rake 'article:import[articles/2026-05-20-name-of-article.md]'" unless path

    CreateArticle.call(path)
  end

  task :import_all do
    require_relative "scripts/create_article"

    Dir.glob("articles/*.md").sort.each do |path|
      CreateArticle.call(path)
    end
  end
end

namespace :page do
  task :import, [:path] do |_task, args|
    require_relative "scripts/create_page"

    path = args[:path]
    abort "Usage: bundle exec rake 'page:import[pages/2026-05-20-name-of-page.md]'" unless path

    CreatePage.call(path)
  end

  task :import_all do
    require_relative "scripts/create_page"

    Dir.glob("pages/*.md").sort.each do |path|
      CreatePage.call(path)
    end
  end
end

namespace :now do
  task :import, [:path] do |_task, args|
    require_relative "scripts/create_now"

    path = args[:path]
    abort "Usage: bundle exec rake 'now:import[nows/2026-05-20-now.md]'" unless path

    CreateNow.call(path)
  end

  task :import_all do
    require_relative "scripts/create_now"

    Dir.glob("nows/*.md").sort.each do |path|
      CreateNow.call(path)
    end
  end
end

task :console do
  require_relative "config/application"
  require "irb"

  ARGV.clear
  IRB.start
end