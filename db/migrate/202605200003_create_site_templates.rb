# frozen_string_literal: true

class CreateSiteTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :site_templates, id: :uuid do |t|
      t.string :key, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_index :site_templates, :key, unique: true
  end
end
