# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailProcessorService do
  let(:email1_content) { File.read(Rails.root.join('emails', 'email1.eml')) }
  let(:email2_content) { File.read(Rails.root.join('emails', 'email2.eml')) }
  let(:unrecognized_email_content) do
    <<~EMAIL
      From: test@example.com
      To: test@example.com
      Subject: Unknown format

      Some content
    EMAIL
  end
  let(:malformed_email_content) do
    <<~EMAIL
      From: loja@fornecedorA.com
      To: vendas@suaempresa.com
      Subject: Pedido de orçamento - Produto ABC123

      Nome do cliente: João da Silva
      E-mail:
      Telefone: (11) 91234-5678
    EMAIL
  end

  describe '.process' do
    context 'with a valid email from Supplier A' do
      it 'creates a new customer and a processing log' do
        expect { described_class.process(email1_content) }.to change(Customer, :count).by(1).and change(ProcessingLog, :count).by(1)
        customer = Customer.last
        expect(customer.name).to eq('João da Silva')
        expect(customer.email).to eq('joao.silva@example.com')
        log = ProcessingLog.last
        expect(log.status).to eq('success')
        expect(log.extracted_data_json['name']).to eq('João da Silva')
      end
    end

    context 'with a valid email from Partner B' do
      it 'creates a new customer and a processing log' do
        expect { described_class.process(email2_content) }.to change(Customer, :count).by(1).and change(ProcessingLog, :count).by(1)
        customer = Customer.last
        expect(customer.name).to eq('Maria Oliveira')
        expect(customer.email).to eq('maria.oliveira@example.com')
        log = ProcessingLog.last
        expect(log.status).to eq('success')
        expect(log.extracted_data_json['name']).to eq('Maria Oliveira')
      end
    end

    context 'with an existing customer' do
      let!(:existing_customer) { Customer.create!(name: 'Old Name', email: 'joao.silva@example.com') }

      it 'updates the customer and creates a processing log' do
        customer_count_before = Customer.count
        log_count_before = ProcessingLog.count

        described_class.process(email1_content)

        expect(Customer.count).to eq(customer_count_before)
        expect(ProcessingLog.count).to eq(log_count_before + 1)

        existing_customer.reload
        expect(existing_customer.name).to eq('João da Silva')
        log = ProcessingLog.last
        expect(log.status).to eq('success')
        expect(log.extracted_data_json['name']).to eq('João da Silva')
      end
    end

    context 'with an unrecognized email format' do
      it 'creates an error processing log' do
        customer_count_before = Customer.count
        log_count_before = ProcessingLog.count

        described_class.process(unrecognized_email_content)

        expect(Customer.count).to eq(customer_count_before)
        expect(ProcessingLog.count).to eq(log_count_before + 1)

        log = ProcessingLog.last
        expect(log.status).to eq('error')
        expect(log.error_message).to eq('Parser not found for this email format.')
      end
    end

    context 'with a malformed email' do
      it 'creates an error processing log' do
        customer_count_before = Customer.count
        log_count_before = ProcessingLog.count

        described_class.process(malformed_email_content)

        expect(Customer.count).to eq(customer_count_before)
        expect(ProcessingLog.count).to eq(log_count_before + 1)

        log = ProcessingLog.last
        expect(log.status).to eq('error')
        expect(log.error_message).to eq('Failed to parse customer data from email.')
      end
    end
    context 'when an error occurs during customer saving' do
      before do
        allow_any_instance_of(Customer).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'creates an error processing log' do
        expect { described_class.process(email1_content) }.to change(ProcessingLog, :count).by(1)

        log = ProcessingLog.last
        expect(log.status).to eq('error')
        expect(log.error_message).to include('Record invalid')
      end

      it 'does not create a new customer' do
        expect { described_class.process(email1_content) rescue nil }.not_to change(Customer, :count)
      end
    end
  end
end
