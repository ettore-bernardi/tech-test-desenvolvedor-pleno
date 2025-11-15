# frozen_string_literal: true

# spec/requests/uploads_spec.rb
require 'rails_helper'

RSpec.describe 'Uploads', type: :request do # rubocop:disable Metrics/BlockLength
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  let(:files_dir) { Rails.root.join('spec', 'files') }
  def fixture_upload(filename)
    Rack::Test::UploadedFile.new(files_dir.join(filename), 'message/rfc822')
  end

  describe 'POST /uploads' do
    it 'creates an upload, creates EmailLogs for each file and enqueues ProcessUploadJob' do
      uploaded_files = [
        fixture_upload('email1.eml'),
        fixture_upload('email2.eml'),
        fixture_upload('email3.eml')
      ]

      expect do
        post uploads_path, params: { eml_files: uploaded_files }
      end.to have_enqueued_job(ProcessUploadJob).with(kind_of(Integer))

      upload = Upload.last
      expect(response).to redirect_to(upload_path(upload))
      expect(upload.files_count).to eq(3)
      expect(EmailLog.where(upload_id: upload.id).count).to eq(3)
    end
  end

  describe 'PATCH /uploads/:id/clear_email_logs_raw' do
    it 'clears raw_data, message and parsed_json for all email_logs of the upload' do
      upload = Upload.create!(files_count: 0, status: 'processing')

      el1 = EmailLog.create!(upload_id: upload.id, file_name: 'email1.eml', raw_data: 'raw1', status: 'success',
                             message: 'ok', parsed_json: { a: 1 })
      el2 = EmailLog.create!(upload_id: upload.id, file_name: 'email2.eml', raw_data: 'raw2', status: 'failed',
                             message: nil, parsed_json: {})
      el3 = EmailLog.create!(upload_id: upload.id, file_name: 'email3.eml', raw_data: nil, status: 'failed',
                             message: 'no raw', parsed_json: {})

      expect(EmailLog.where(upload_id: upload.id).where.not(raw_data: nil).count).to eq(2)

      patch "/uploads/#{upload.id}/clear_email_logs_raw", headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['cleared'].to_i).to eq(3)
      [el1, el2, el3].each(&:reload)
      expect(el1.raw_data).to be_nil
      expect(el1.message).to be_nil
      expect(el1.parsed_json).to eq({}.as_json)
      expect(el2.raw_data).to be_nil
      expect(el2.message).to be_nil
      expect(el2.parsed_json).to eq({}.as_json)
      expect(el3.raw_data).to be_nil
      expect(el3.message).to be_nil
    end
  end
end
