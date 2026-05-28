# Sinatra PostgreSQL Site

A small database-first Sinatra application.

PostgreSQL stores articles, stores HTML templates, and exposes rendering functions that return a JSON HTTP payload. Sinatra stays thin and serves the payload.

## Requirements

- Ruby 3.3+
- PostgreSQL
- Bundler

## Setup

```bash
bundle install
bundle exec rake db:setup
bundle exec rake article:import_all
bundle exec puma -C config/puma.rb
```

Open:

```txt
http://localhost:4567/articles
```

## Create a new article

Create a Markdown file in `articles/`:

```txt
articles/2026-05-20-name-of-article.md
```

Example:

```md
---
title: Name of Article
published: true
---

Write your article here.

```ruby
puts "Hello from Ruby"
```
```

Import it:

```bash
bundle exec ruby scripts/create_article.rb articles/2026-05-20-name-of-article.md
```

Or:

```bash
bundle exec rake 'article:import[articles/2026-05-20-name-of-article.md]'
```

## Useful commands

```bash
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake article:import_all
bundle exec puma -C config/puma.rb
```

## Main idea

```txt
Markdown file
  -> Ruby importer
  -> PostgreSQL articles table
  -> PostgreSQL render function
  -> Sinatra HTTP response
```

## Notes

This app uses ActiveRecord for migrations, models, and database tasks. The public rendering path still goes through PostgreSQL functions.
