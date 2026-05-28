# frozen_string_literal: true
# 
class CreateRenderNowFunction < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      create or replace function render_now()
      returns jsonb
      language plpgsql
      as $$
      declare
        now_record nows;
        template_record site_templates;
        rendered_body text;
      begin
        select *
        into now_record
        from nows
        where published = true
        order by published_on desc nulls last, created_at desc
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
        where key = now_record.template_key
        limit 1;

        if not found then
          return jsonb_build_object(
            'status', 500,
            'headers', jsonb_build_object('content-type', 'text/plain; charset=utf-8'),
            'body', 'Template missing: ' || now_record.template_key
          );
        end if;

        rendered_body := template_record.body;
        rendered_body := replace(rendered_body, '{{title}}', now_record.title);
        rendered_body := replace(rendered_body, '{{body}}', now_record.html_body);

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
    execute <<~SQL
      drop function if exists render_now();
    SQL
  end
end