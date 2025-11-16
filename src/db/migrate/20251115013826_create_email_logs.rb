# frozen_string_literal: true

class CreateEmailLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :email_logs do |t|
      t.string :file_name
      t.text :raw_data
      t.string :status
      t.string :content_hash
      t.text :message
      t.json :parsed_json, default: {}
      t.references :upload

      t.timestamps
    end
  end
end
