require 'rails_helper'

RSpec.describe EmailParserService do
  describe '#parse' do
    context 'with a valid email (email1.eml)' do
      it 'extracts the customer data' do
        email_body = File.read(Rails.root.join('spec', 'fixtures', 'files', 'email.eml'))
        service = EmailParserService.new(email_body)
        result = service.parse

        expect(result[:name]).to eq('João da Silva')
        expect(result[:email]).to eq('joao.silva@example.com')
        expect(result[:phone]).to eq('(11) 91234-5678')
        expect(result[:product_code]).to eq('ABC123')
      end
    end

    context 'with a valid email (email2.eml)' do
      it 'extracts the customer data' do
        email_body = File.read(Rails.root.join('emails', 'email2.eml'))
        service = EmailParserService.new(email_body)
        result = service.parse

        expect(result[:name]).to eq('Maria Oliveira')
        expect(result[:email]).to eq('maria.oliveira@example.com')
        expect(result[:phone]).to eq('21 99876-5432')
        expect(result[:product_code]).to eq('XYZ987')
      end
    end

    context 'with an email missing phone (email3.eml)' do
      it 'returns nil for the missing phone field' do
        email_body = File.read(Rails.root.join('emails', 'email3.eml'))
        service = EmailParserService.new(email_body)
        result = service.parse

        expect(result[:name]).to eq('Pedro Santos')
        expect(result[:email]).to eq('pedro.santos@example.com')
        expect(result[:phone]).to be_nil
        expect(result[:product_code]).to eq('LMN456')
      end
    end

    context 'with an email missing data' do
      it 'returns nil for the missing fields' do
        email_body = "From: sender@example.com\nTo: receiver@example.com\nSubject: Incomplete Data\n\nNome do cliente: Jane Doe\nE-mail: jane.doe@example.com"
        service = EmailParserService.new(email_body)
        result = service.parse

        expect(result[:name]).to eq('Jane Doe')
        expect(result[:email]).to eq('jane.doe@example.com')
        expect(result[:phone]).to be_nil
        expect(result[:product_code]).to be_nil
      end
    end
  end
end
