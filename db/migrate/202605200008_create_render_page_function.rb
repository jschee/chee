# frozen_string_literal: true

class CreateRenderPageFunction < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      create or replace function render_page(page_slug text)
      returns jsonb
      language plpgsql
      as $$
      declare
        page_record pages;
        template_record site_templates;
        rendered_body text;
      begin
        select *
        into page_record
        from pages
        where slug = page_slug
          and published = true
        limit 1;

        if not found then
          return jsonb_build_object(
            'status', 404,
            'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
            'body', '<!doctype html><html><head><title>404</title><link rel="stylesheet" href="/css/site.css"></head><body class="roboto-flex"><main class="page"><h1>404</h1><p>Sorry nothing was found :(</p><p><a href="/">chee.sh</a></p></main></body></html>'
          );
        end if;

        select *
        into template_record
        from site_templates
        where key = 'page'
        limit 1;

        if not found then
          return jsonb_build_object(
            'status', 500,
            'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
            'body', '<h1>Template missing</h1><p>Expected site_templates.key = page.</p>'
          );
        end if;

        rendered_body := template_record.body;
        rendered_body := replace(rendered_body, '{{title}}', page_record.title);
        rendered_body := replace(rendered_body, '{{published_on}}', coalesce(page_record.published_on::text, ''));
        rendered_body := replace(rendered_body, '{{slug}}', page_record.slug);
        rendered_body := replace(rendered_body, '{{body}}', page_record.html_body);

        return jsonb_build_object(
          'status', 200,
          'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
          'body', rendered_body
        );
      end;
      $$;
    SQL

    execute <<~SQL
      create or replace function render_page_index()
      returns jsonb
      language plpgsql
      as $$
      declare
        template_record site_templates;
        rendered_body text;
        page_list text;
      begin
        select *
        into template_record
        from site_templates
        where key = 'page_index'
        limit 1;

        if not found then
          return jsonb_build_object(
            'status', 500,
            'headers', jsonb_build_object('content-type', 'text/html; charset=utf-8'),
            'body', '<h1>Template missing</h1><p>Expected site_templates.key = page_index.</p>'
          );
        end if;

        select coalesce(string_agg(
          '<page class="page-card"><p class="date">' || coalesce(published_on::text, '') || '</p><h2><a href="/pages/' || slug || '">' || title || '</a></h2></page>',
          E'\n'
          order by published_on desc nulls last, created_at desc
        ), '<p>No pages have been published yet.</p>')
        into page_list
        from pages
        where published = true;

        rendered_body := replace(template_record.body, '{{pages}}', page_list);

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
    execute "drop function if exists render_page(text);"
    execute "drop function if exists render_page_index();"
  end
end
