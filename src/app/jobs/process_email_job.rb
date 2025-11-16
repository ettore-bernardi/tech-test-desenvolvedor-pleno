# frozen_string_literal: true

# app/jobs/process_email_job.rb
class ProcessEmailJob < ApplicationJob
  queue_as :default

  def perform(email_log_id) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    email_log = EmailLog.find_by(id: email_log_id)
    return unless email_log

    processor = EmailProcessor.new(raw_eml: email_log.raw_data, file_name: email_log.file_name)
    result = processor.process_and_return_result

    # opcional: atualiza defensivamente caso processor não tenha atualizado
    email_log.update!(
      status: (result[:status] == :success ? 'success' : 'failed'),
      message: result[:message],
      parsed_json: result[:parsed] || email_log.parsed_json || {}
    )
  rescue StandardError => e
    Rails.logger.error("[ProcessEmailJob] email_log=#{email_log_id} error: #{e.class}: #{e.message}")
    email_log&.update(status: 'failed', message: "Exception: #{e.class}: #{e.message}")
  end
end
