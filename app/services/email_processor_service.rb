# frozen_string_literal: true

class EmailProcessorService
  def self.process(email_content)
    new(email_content).process
  end

  def initialize(email_content)
    @mail = Mail.read_from_string(email_content)
  end

  def process
    parser_class = determine_parser
    unless parser_class
      log_error("Parser not found for this email format.")
      return
    end

    parser = parser_class.new(@mail.to_s)
    data = parser.parse

    if data
      customer = Customer.find_or_initialize_by(email: data[:email])
      customer.name = data[:name]
      customer.phone = data[:phone] if data.key?(:phone)
      customer.save!

      log_success(data)
      customer
    else
      log_error("Failed to parse customer data from email.")
      nil
    end
  rescue => e
    log_error("An error occurred: #{e.message}")
    nil
  end

  private

  def determine_parser
    if @mail.subject&.include?("Pedido de orçamento")
      Parsers::SupplierA
    elsif @mail.subject&.include?("Interesse no produto")
      Parsers::PartnerB
    end
  end

  def log_success(data)
    ProcessingLog.create!(
      status: "success",
      extracted_data_json: data
    )
  end

  def log_error(message)
    ProcessingLog.create!(
      status: "error",
      error_message: message
    )
  end
end
