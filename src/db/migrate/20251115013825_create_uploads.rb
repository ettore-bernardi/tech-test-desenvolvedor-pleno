# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    create_table :uploads do |t|
      t.string :description
      t.integer :files_count, default: 0
      t.string :status, default: 'pending'
      t.timestamps
    end
  end
end
