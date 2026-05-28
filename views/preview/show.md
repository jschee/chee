<h3 class="roboto-flex">What I use for my personal website</h3>

*Last updated 05/28/2026*

To become more tech independent, I am hosting my own websites and web applications on my own server. This migration has helped me better understand deployment, servers, databases, caching, and how the web works beyond just writing application code. I also moved away from static site generators and strung together my very own omakase.

What I use:
- [postgresql](https://www.postgresql.org/) - stores content, templates, and render functions
- [sinatra](https://sinatrarb.com/) - a small ruby DSL for handling web routes
- [ruby](https://www.ruby-lang.org/en/) - scripts, imports, and application glue
- [activerecord](https://github.com/rails/rails/tree/v8.1.3/activerecord) - database migrations and ruby object mapping
- [mustache](https://mustache.github.io/) - template placeholders
- [redcarpet](https://github.com/vmg/redcarpet) - converts markdown into HTML
- [kamal 2](https://kamal-deploy.org/) - deploys the app as containers
- [hetzner](https://www.hetzner.com/cloud/) - vps hosting
- [bunny](https://bunny.net/) - cdn and media storage

The publishing workflow:

I write a page, article, or now in markdown and preview it locally on the site.
⇣
I run a ruby script that reads the file, parses the frontmatter, converts the markdown to HTML, and saves it to postgresql.
⇣
The page record points to a template key, such as page, article, or now.
⇣
When someone visits the url, sinatra calls a postgresql function.
⇣
Postgresql maps the resource via slug, combines the saved content with the matching template and returns a HTML response.
⇣
Sinatra sends that HTML response to the browser for your viewing pleasure 😊.

Feel free to reach out if you have any questions, opinions, or interest.