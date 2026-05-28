# frozen_string_literal: true

class CreateRenderFunctions < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      create or replace function render_article(article_slug text)
      returns jsonb
      language plpgsql
      as $$
      declare
        article_record articles;
        template_record site_templates;
        rendered_body text;
      begin
        select *
        into article_record
        from articles
        where slug = article_slug
          and published = true
        limit 1;

        if not found then
          return jsonb_build_object(
            'status', 404,
            'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
            'body', '<!doctype html><html><head><title>404</title><link rel="stylesheet" href="/css/site.css"></head><body class="roboto-flex"><main class="page"><h1>404</h1><p>Article not found.</p><p><a href="/">chee.sh</a></p></main></body></html>'
          );
        end if;

        select *
        into template_record
        from site_templates
        where key = 'article'
        limit 1;

        if not found then
          return jsonb_build_object(
            'status', 500,
            'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
            'body', '<h1>Template missing</h1><p>Expected site_templates.key = article.</p>'
          );
        end if;

        rendered_body := template_record.body;
        rendered_body := replace(rendered_body, '{{title}}', article_record.title);
        rendered_body := replace(rendered_body, '{{published_on}}', coalesce(article_record.published_on::text, ''));
        rendered_body := replace(rendered_body, '{{body}}', article_record.html_body);

        return jsonb_build_object(
          'status', 200,
          'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
          'body', rendered_body
        );
      end;
      $$;
    SQL

    execute <<~SQL
      create or replace function render_article_index()
      returns jsonb
      language plpgsql
      as $$
      declare
        template_record site_templates;
        rendered_body text;
        article_list text;
      begin
        select *
        into template_record
        from site_templates
        where key = 'article_index'
        limit 1;

        if not found then
          return jsonb_build_object(
            'status', 500,
            'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
            'body', '<h1>Template missing</h1><p>Expected site_templates.key = article_index.</p>'
          );
        end if;

        select coalesce(string_agg(
          '<article class="article-card"><p class="date">' || coalesce(published_on::text, '') || '</p><h2><a href="/articles/' || slug || '">' || title || '</a></h2></article>',
          E'\n'
          order by published_on desc nulls last, created_at desc
        ), '<p>No articles have been published yet.</p>')
        into article_list
        from articles
        where published = true;

        rendered_body := replace(template_record.body, '{{articles}}', article_list);

        return jsonb_build_object(
          'status', 200,
          'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
          'body', rendered_body
        );
      end;
      $$;
    SQL
  end

  def down
    execute "drop function if exists render_article(text);"
    execute "drop function if exists render_article_index();"
  end
end
