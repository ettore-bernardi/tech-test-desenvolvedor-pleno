# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parsers::SupplierA do
  describe '#parse' do
    let(:valid_body) do
      <<~EMAIL
        Olá equipe,

        Gostaria de solicitar informações sobre o produto de código ABC123.

        Nome do cliente: João da Silva
        E-mail: joao.silva@example.com
        Telefone: (11) 91234-5678

        Atenciosamente,
        João da Silva
      EMAIL
    end

    let(:missing_name_body) do
      <<~EMAIL
        E-mail: joao.silva@example.com
        Telefone: (11) 91234-5678
      EMAIL
    end

    let(:missing_email_body) do
      <<~EMAIL
        Nome do cliente: João da Silva
        Telefone: (11) 91234-5678
      EMAIL
    end

    let(:empty_body) { '' }

    context 'with a valid email body' do
      it 'extracts the customer data' do
        parser = described_class.new(valid_body)
        result = parser.parse
        expect(result).to eq({
          name: 'João da Silva',
          email: 'joao.silva@example.com',
          phone: '(11) 91234-5678'
        })
      end
    end

    context 'when the name is missing' do
      it 'returns nil' do
        parser = described_class.new(missing_name_body)
        expect(parser.parse).to be_nil
      end
    end

    context 'when the email is missing' do
      it 'returns nil' do
        parser = described_class.new(missing_email_body)
        expect(parser.parse).to be_nil
      end
    end

    context 'with an empty email body' do
      it 'returns nil' do
        parser = described_class.new(empty_body)
        expect(parser.parse).to be_nil
      end
    end
  end
end
