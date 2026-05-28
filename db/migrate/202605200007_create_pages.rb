# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages, id: :uuid do |t|
      t.string :slug, null: false
      t.string :title
      t.string :template_key, null: false
      t.string :format, null: false, default: "markdown"
      t.text :raw_body, null: false
      t.text :html_body
      t.boolean :published, null: false, default: false
      t.date :published_on
      t.string :source_path
      t.timestamps
    end

    add_index :pages, :slug, unique: true
    add_index :pages, :published
    add_index :pages, :published_on
    add_index :pages, :source_path, unique: true
  end
end
