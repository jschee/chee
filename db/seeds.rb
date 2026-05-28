# frozen_string_literal: true

require_relative "../config/database"
require_relative "../app/models/site_template"

SiteTemplate.upsert(
  {
    key: "article",
    body: <<~HTML,
      <!doctype html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>{{title}}</title>
        <link rel="stylesheet" href="/css/site.css">
      </head>
      <body>
        <main class="page article-page">
          <nav class="top-nav"><a href="/articles">Articles</a></nav>
          <article>
            <p class="date">{{published_on}}</p>
            <h1>{{title}}</h1>
            <div class="content">{{body}}</div>
          </article>
        </main>
      </body>
      </html>
    HTML
    updated_at: Time.now,
    created_at: Time.now
  },
  unique_by: :index_site_templates_on_key
)

SiteTemplate.upsert(
  {
    key: "article_index",
    body: <<~HTML,
      <!doctype html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Articles</title>
        <link rel="stylesheet" href="/css/site.css">
      </head>
      <body>
        <main class="page">
          <section class="hero">
            <p class="eyebrow">Sinatra + PostgreSQL</p>
            <h1>Articles rendered from the database</h1>
            <p>This index page is assembled by a PostgreSQL function and served by a tiny Sinatra route.</p>
          </section>
          <section class="article-list">
            {{articles}}
          </section>
        </main>
      </body>
      </html>
    HTML
    updated_at: Time.now,
    created_at: Time.now
  },
  unique_by: :index_site_templates_on_key
)

puts "Seeded site templates."
