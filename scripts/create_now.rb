# frozen_string_literal: true

require "date"
require "yaml"
require "redcarpet"
require "active_record"
require "pathname"
require "dotenv/load" if ENV.fetch("RACK_ENV", "development") != "production"

require_relative "../config/database"
require_relative "../app/models/now"

class CreateNow
  NOW_FILENAME_PATTERN = /\A(?<date>\d{4}-\d{2}-\d{2})-(?<slug>.+)\.md\z/

  def self.call(path)
    new(path).call
  end

  def initialize(path)
    @path = File.expand_path(path)
  end

  def call
    validate_file!

    date = parsed_filename.fetch(:date)
    slug = [parsed_filename.fetch(:date), parsed_filename.fetch(:slug)].join("-")
    frontmatter, markdown_body = parse_frontmatter(file_body)
    title = frontmatter.fetch("title") { title_from_slug(slug) }
    published = frontmatter.fetch("published", true)
    html_body = render_markdown(markdown_body)
    template_key = frontmatter.fetch("template", "now")

    now = Now.find_or_initialize_by(slug: slug)
    now.assign_attributes(
      slug: slug,
      title: title,
      template_key: template_key,
      format: "markdown",
      raw_body: markdown_body,
      html_body: html_body,
      published: published,
      published_on: date,
      source_path: relative_source_path,
      created_at: Time.now,
      updated_at: Time.now  
    )
    now.save!

    puts "Now saved: #{now.title}"
    puts "Slug: #{now.slug}"
    puts "URL: /nows/#{now.slug}"
  ensure
    ActiveRecord::Base.connection_handler.clear_active_connections!
  end

  private

  def validate_file!
    raise ArgumentError, "File not found: #{@path}" unless File.file?(@path)
    raise ArgumentError, "Filename must look like: 2026-05-20-name-of-now.md" unless parsed_filename
  end

  def parsed_filename
    @parsed_filename ||= begin
      match = File.basename(@path).match(NOW_FILENAME_PATTERN)

      if match
        {
          date: Date.parse(match[:date]),
          slug: match[:slug]
        }
      end
    end
  end

  def file_body
    @file_body ||= File.read(@path)
  end

  def parse_frontmatter(text)
    return [{}, text.strip] unless text.start_with?("---\n")

    _before, yaml_block, markdown_body = text.split("---\n", 3)
    frontmatter = YAML.safe_load(yaml_block, permitted_classes: [Date], aliases: false) || {}

    [frontmatter, markdown_body.to_s.strip]
  end

  def render_markdown(markdown_body)
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

    markdown.render(markdown_body)
  end

  def title_from_slug(slug)
    slug.split("-").map(&:capitalize).join(" ")
  end

  def relative_source_path
    Pathname.new(@path).relative_path_from(Pathname.new(Dir.pwd)).to_s
  rescue ArgumentError
    @path
  end
end

if __FILE__ == $PROGRAM_NAME
  path = ARGV.fetch(0) do
    abort "Usage: bundle exec ruby scripts/create_now.rb nows/2026-05-20-name-of-now.md"
  end

  CreateNow.call(path)
end
