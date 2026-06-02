require './app' # Load your Sinatra app
require 'erb'


@slugs = Page.all.map { |page| [page.slug, page.created_at.strftime("%Y-%m-%d")] }

xml = <<~ERB
  <urlset>
    <% @slugs.each do |slug| %>
      <url>
        <loc>http://chee.sh/<%= slug[0] %></loc>
        <lastmod><%= slug[1] %></lastmod>
      </url>
    <% end %>
  </urlset>
ERB

xml_body = ERB.new(xml).result(binding)

File.write('public/sitemap.xml', xml_body)

puts "sitemap has been generated successfully."