# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parsers::PartnerB do
  describe '#parse' do
    let(:valid_body) do
      <<~EMAIL
        Prezados,

        Estou interessado no produto de código XYZ987.

        Dados de contato:
        Nome: Maria Oliveira
        E-mail: maria.oliveira@example.com
        Telefone: 21 99876-5432

        Aguardo retorno.
      EMAIL
    end

    let(:missing_name_body) do
      <<~EMAIL
        Dados de contato:
        E-mail: maria.oliveira@example.com
        Telefone: 21 99876-5432
      EMAIL
    end

    let(:missing_email_body) do
      <<~EMAIL
        Dados de contato:
        Nome: Maria Oliveira
        Telefone: 21 99876-5432
      EMAIL
    end

    let(:empty_body) { '' }

    context 'with a valid email body' do
      it 'extracts the customer data' do
        parser = described_class.new(valid_body)
        result = parser.parse
        expect(result).to eq({
          name: 'Maria Oliveira',
          email: 'maria.oliveira@example.com',
          phone: '21 99876-5432'
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
