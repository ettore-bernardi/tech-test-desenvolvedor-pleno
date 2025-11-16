# frozen_string_literal: true

# app/services/email_processor.rb
require 'mail'
require 'digest'

class EmailProcessor # rubocop:disable Style/Documentation
  PARSERS = {
    /fornecedorA.com/i => Parsers::FornecedorAParser,
    /parceiroB.com/i => Parsers::ParceiroBParser
  }.freeze

  def initialize(raw_eml:, file_name: nil)
    @raw = raw_eml.to_s
    @file_name = file_name
    @mail = begin
      Mail.read_from_string(@raw)
    rescue StandardError
      Mail.new
    end
  end

  def process_and_return_result # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    content_hash = Digest::SHA256.hexdigest(@raw)
    email_log = EmailLog.find_or_create_by(content_hash: content_hash) do |e|
      e.file_name = @file_name
      e.raw_data = @raw
      e.status = 'pending'
    end

    parser_class = detect_parser
    unless parser_class
      update_log_with(email_log, 'failed', "No parser for from: #{Array(@mail.from).join(',')}", {})
      return { status: :failed, message: 'No parser found', parsed: {} }
    end

    parser = parser_class.new(@mail)
    result = parser.parse # espera um hash

    if valid_result?(result)
      if defined?(Customer)
        customer = Customer.create!(name: result[:name], email: result[:email], phone: result[:phone],
                                    product_code: result[:product_code])
      end
      update_log_with(email_log, 'success', 'Parsed successfully', result)
      { status: :success, message: 'Parsed successfully', parsed: result, customer: customer }
    else
      update_log_with(email_log, 'failed', 'Missing contact info', result || {})
      { status: :failed, message: 'Missing contact info', parsed: result || {} }
    end
  rescue StandardError => e
    Rails.logger.error("[EmailProcessor] error: #{e.class}: #{e.message}\n#{e.backtrace.first(10).join("\n")}")
    email_log ||= EmailLog.find_or_create_by(content_hash: Digest::SHA256.hexdigest(@raw)) do |el|
      el.file_name = @file_name
      el.raw_data = @raw
    end
    update_log_with(email_log, 'failed', "Exception: #{e.class}: #{e.message}", {})
    { status: :failed, message: "Exception: #{e.class}: #{e.message}", parsed: {} }
  end

  private

  def detect_parser
    from = Array(@mail.from).join(' ')
    PARSERS.find { |pattern, _klass| from.match?(pattern) }&.last
  end

  def valid_result?(res)
    res && res[:name].to_s.strip != '' && res[:email].to_s.strip != ''
  end

  def update_log_with(email_log, status, message, parsed)
    email_log.update!(
      status: status,
      message: message,
      parsed_json: parsed
    )
  end
end
