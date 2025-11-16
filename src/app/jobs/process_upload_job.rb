# frozen_string_literal: true

# app/jobs/process_upload_job.rb
class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload_id) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    upload = Upload.find_by(id: upload_id)
    return unless upload

    upload.update!(status: 'processing') if upload.respond_to?(:status)

    upload.email_logs.where(status: ['pending', nil]).order(:created_at).find_each do |email_log| # rubocop:disable Metrics/BlockLength
      max_attempts = 6
      attempt = 0

      begin
        ProcessEmailJob.perform_later(email_log.id)
      rescue ActiveRecord::StatementInvalid => e
        msg = e.message.to_s
        raise unless msg =~ /database is locked/i || msg =~ /SQLite3::BusyException/i

        attempt += 1

        if attempt <= max_attempts
          sleep_time = 0.5 * attempt
          Rails.logger.warn("[ProcessUploadJob] SQLite lock detected for email_log=#{email_log.id} (attempt #{attempt}/#{max_attempts}), retrying in #{sleep_time}s") # rubocop:disable Layout/LineLength
          sleep sleep_time
          retry
        else
          Rails.logger.error("[ProcessUploadJob] Giving up enqueuing ProcessEmailJob for email_log=#{email_log.id} after #{max_attempts} attempts due to persistent DB lock") # rubocop:disable Layout/LineLength
          begin
            if email_log.respond_to?(:update)
              begin
                email_log.update(status: 'failed', message: 'Enqueue failed: DB locked')
              rescue StandardError # rubocop:disable Metrics/BlockNesting
                nil
              end
            end
          rescue StandardError => _ign # rubocop:disable Lint/SuppressedException
          end
        end
      rescue StandardError => e
        Rails.logger.error("[ProcessUploadJob] error enqueuing ProcessEmailJob for email_log=#{email_log.id}: #{e.class}: #{e.message}") # rubocop:disable Layout/LineLength
      end
    end

    upload.update!(status: 'finished') if upload.respond_to?(:status)
  rescue StandardError => e
    Rails.logger.error("[ProcessUploadJob] upload=#{upload_id} error: #{e.class}: #{e.message}\n#{e.backtrace&.first(10)&.join("\n")}") # rubocop:disable Layout/LineLength
    raise
  end
end
