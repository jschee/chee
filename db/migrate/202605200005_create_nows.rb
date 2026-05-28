# frozen_string_literal: true

class CreateNows < ActiveRecord::Migration[8.0]
  def change
    create_table :nows, id: :uuid do |t|
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

    add_index :nows, :slug, unique: true
    add_index :nows, :published
    add_index :nows, :published_on
    add_index :nows, :source_path, unique: true
  end
end
