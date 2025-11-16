# frozen_string_literal: true

class Upload < ApplicationRecord
  has_many :email_logs, foreign_key: :upload_id, dependent: :nullify

  enum status: {
    pending: 'pending',
    processing: 'processing',
    finished: 'finished',
    failed: 'failed'
  }

  def check_completion!
    done = email_logs.where.not(email_logs: { status: %w[processing pending] }).count

    return if total.zero?

    return unless done == total

    finalize_upload!
  end

  def finalize_upload!
    errors_count = email_logs.where(status: %w[failed error]).count

    final_status =
      if errors_count.zero?
        :finished
      else
        :failed
      end

    update!(status: final_status)

    # Criar log apenas se houver pelo menos um email processado
    return unless total_emails.positive? && email_logs.any?

    # Log já é criado individualmente por email, não precisa criar um log geral
    Rails.logger.info("Upload ##{id} finalizado com status: #{final_status}. #{total_emails} email(s) processado(s).")
  end
end
