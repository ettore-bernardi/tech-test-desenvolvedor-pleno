# frozen_string_literal: true

# spec/services/email_processor_spec.rb
require 'rails_helper'
require 'digest'

RSpec.describe EmailProcessor, type: :service do
  it 'parses fornecedor A sample' do
    fixture_paths = [
      Rails.root.join('spec', 'fixtures', 'fornecedorA_01.eml'),
      Rails.root.join('spec', 'files', 'fornecedorA_01.eml')
    ]

    fixture_path = fixture_paths.find { |p| File.exist?(p) }
    skip 'fixture fornecedorA_01.eml missing in spec/fixtures or spec/files' unless fixture_path

    raw = File.read(fixture_path)

    content_hash = Digest::SHA256.hexdigest(raw.to_s)
    EmailLog.where(content_hash: content_hash).delete_all

    processor = EmailProcessor.new(raw_eml: raw, file_name: 'fornecedorA_01.eml')
    res = processor.process_and_return_result

    expect(res).to be_a(Hash)
    expect(res).to have_key(:status)
    expect(res[:status]).to eq(:success)
  end
end
