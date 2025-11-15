# frozen_string_literal: true

# spec/requests/uploads_clear_email_logs_raw_spec.rb
require 'rails_helper'

RSpec.describe 'Uploads#clear_email_logs_raw', type: :request do
  describe 'PATCH /uploads/:id/clear_email_logs_raw' do
    it 'clears raw_data, message and parsed_json for all email_logs of the upload' do
      upload = Upload.create!(files_count: 0, status: 'processing')

      el1 = EmailLog.create!(upload_id: upload.id, file_name: 'email1.eml', raw_data: 'raw1', status: 'success',
                             message: 'ok', parsed_json: { a: 1 })
      el2 = EmailLog.create!(upload_id: upload.id, file_name: 'email2.eml', raw_data: 'raw2', status: 'failed',
                             message: nil, parsed_json: { 'x' => 2 })
      el3 = EmailLog.create!(upload_id: upload.id, file_name: 'email3.eml', raw_data: nil, status: 'failed',
                             message: 'no raw', parsed_json: {})

      expect(EmailLog.where(upload_id: upload.id).where.not(raw_data: nil).count).to eq(2)

      patch "/uploads/#{upload.id}/clear_email_logs_raw", headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['cleared'].to_i).to eq(3)

      [el1, el2, el3].each(&:reload)
      [el1, el2, el3].each do |el|
        expect(el.raw_data).to be_nil
        expect(el.message).to be_nil
        expect(el.parsed_json).to eq({}.as_json)
      end
    end

    it 'returns 404 when upload not found' do
      patch '/uploads/999999/clear_email_logs_raw', headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['success']).to be false
      expect(json['error']).to match(/not found/i)
    end

    it 'returns 500 when update_all raises an exception' do
      upload = Upload.create!(files_count: 0, status: 'processing')
      EmailLog.create!(upload_id: upload.id, file_name: 'email1.eml', raw_data: 'raw1', status: 'success')

      allow_any_instance_of(ActiveRecord::Relation).to receive(:update_all).and_raise(StandardError.new('boom'))

      patch "/uploads/#{upload.id}/clear_email_logs_raw", headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:internal_server_error)
      json = JSON.parse(response.body)
      expect(json['success']).to be false
      expect(json['error']).to match(/boom/)
    end
  end
end
