# frozen_string_literal: true

require "sinatra/base"
require "json"
require "dotenv/load" if ENV.fetch("RACK_ENV", "development") != "production"
require "redcarpet"

require_relative "config/database"
require_relative "app/models/article"
require_relative "app/models/now"
require_relative "app/models/page"
require_relative "app/models/site_template"

class App < Sinatra::Base

  # comment out only for ngrok
  # disable :protection
  # def self.setup_host_authorization(*)
  #   self
  # end
# 
#

  configure do
    set :root, File.dirname(__FILE__)
    set :public_folder, File.join(root, "public")
  end

  after do
    ActiveRecord::Base.connection_handler.clear_active_connections!
  end 

  get "/up" do
    status 200
    content_type "text/plain"
    "ok"
  end

  get "/" do
    erb :"home/show", layout: :"layouts/application"
  end

  get "/articles" do
    payload = pg_response("select render_article_index()::text as response")
    send_pg_payload(payload)
  end

  get "/articles/:slug" do
    payload = pg_response("select render_article($1)::text as response", [params[:slug]])
    send_pg_payload(payload)
  end

  get "/now" do
    payload = pg_response("select render_now()::text as response")
    send_pg_payload(payload)
  end

  get "/p" do
    markdown_path = File.join(settings.views, "preview/show.md")

    @content = render_markdown(File.read(markdown_path))

    erb :"preview/show", layout: :"layouts/application"
  end


  get "/:slug" do
    payload = pg_response("select render_page($1)::text as response", [params[:slug]])
    send_pg_payload(payload)
  end

  private

  def pg_response(sql, params = [])
    raw = ActiveRecord::Base.connection.raw_connection
    result = raw.exec_params(sql, params)
    JSON.parse(result.first.fetch("response"))
  end

  def send_pg_payload(payload)
    status payload.fetch("status")

    payload.fetch("headers", {}).each do |key, value|
      headers[key] = value
    end

    payload.fetch("body")
  end

  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      hard_wrap: true
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      fenced_code_blocks: true,
      tables: true,
      autolink: true,
      strikethrough: true
    )

    markdown.render(text)
  end
end
