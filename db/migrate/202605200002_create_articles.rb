# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles, id: :uuid do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :template_key, null: false
      t.string :format, null: false, default: "markdown"
      t.text :raw_body, null: false
      t.text :html_body, null: false
      t.boolean :published, null: false, default: false
      t.date :published_on
      t.string :source_path

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :published
    add_index :articles, :published_on
    add_index :articles, :source_path, unique: true
  end
end
