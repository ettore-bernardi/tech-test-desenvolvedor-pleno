require 'rails_helper'

RSpec.describe Parsers::Base do
  let(:email_content) { "Subject: Test Email\n\nBody of the email." }
  let(:parser) { Class.new(described_class).new(email_content) }

  describe '#initialize' do
    it 'initializes with an email content' do
      expect(parser).to be_present
      expect(parser.mail).to be_a(Mail::Message)
      expect(parser.mail.subject).to eq('Test Email')
      expect(parser.mail.body.to_s).to include('Body of the email.')
    end
  end

  describe '#parse' do
    it 'raises a NotImplementedError' do
      expect { parser.parse }.to raise_error(NotImplementedError, /has not implemented method 'parse'/)
    end
  end

  describe '#extract_field' do
    let(:content) { "Key1: Value1\nKey2:   Value2  \n" }

    it 'extracts a field when a pattern matches' do
      patterns = [ /Key1: (.*)/ ]
      expect(parser.send(:extract_field, content, patterns)).to eq('Value1')
    end

    it 'extracts a field and strips whitespace' do
      patterns = [ /Key2: (.*)/ ]
      expect(parser.send(:extract_field, content, patterns)).to eq('Value2')
    end

    it 'returns nil when no pattern matches' do
      patterns = [ /NonExistentKey: (.*)/ ]
      expect(parser.send(:extract_field, content, patterns)).to be_nil
    end

    it 'extracts the first matching field among multiple patterns' do
      patterns = [ /Key2: (.*)/, /Key1: (.*)/ ]
      expect(parser.send(:extract_field, content, patterns)).to eq('Value2')
    end

    it 'extracts a field when a later pattern matches' do
      content_no_key1 = "Key3: Value3\nKey2:   Value2  \n"
      patterns = [ /Key1: (.*)/, /Key2: (.*)/ ]
      expect(parser.send(:extract_field, content_no_key1, patterns)).to eq('Value2')
    end
  end
end
