class CreateProcessingLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :processing_logs do |t|
      t.string :status
      t.text :error_message
      t.jsonb :extracted_data_json

      t.timestamps
    end
  end
end
