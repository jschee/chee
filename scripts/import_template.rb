# frozen_string_literal: true

require_relative "../config/application"

class ImportTemplate
  TEMPLATE_PATTERN = /\A(?<key>[a-z0-9_\/-]+)\.html\z/

  def self.call(path)
    new(path).call
  end

  def initialize(path)
    @path = path
  end

  def call
    validate!

    key = template_key
    body = File.read(@path)

    SiteTemplate.upsert(
      {
        key: key,
        body: body,
        created_at: Time.now,
        updated_at: Time.now
      },
      unique_by: :index_site_templates_on_key
    )

    puts "Template saved: #{key}"
  end

  private

  def validate!
    raise ArgumentError, "Template not found: #{@path}" unless File.file?(@path)

    unless File.basename(@path).match?(TEMPLATE_PATTERN)
      raise ArgumentError, "Template filename must look like article.html or article_index.html"
    end
  end

  def template_key
    File.basename(@path, ".html")
  end
end

if __FILE__ == $PROGRAM_NAME
  path = ARGV.fetch(0) do
    abort "Usage: ruby scripts/import_template.rb templates/article.html"
  end

  ImportTemplate.call(path)
end