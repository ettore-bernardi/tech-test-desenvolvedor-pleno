# frozen_string_literal: true

class EmailLogsController < ApplicationController # rubocop:disable Style/Documentation
  def raw # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    email_log = EmailLog.find_by(id: params[:id])
    return head :not_found unless email_log

    raw = (email_log.raw_data || '').dup
    utf8 = begin
      if raw.encoding == Encoding::UTF_8 && raw.valid_encoding?
        raw
      else
        raw = raw.force_encoding('BINARY') unless raw.frozen?
        raw.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      end
    rescue StandardError => _e
      raw.to_s.force_encoding('BINARY').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    end

    render json: {
      id: email_log.id,
      file_name: email_log.file_name,
      status: email_log.status,
      raw: utf8
    }
  end

  def clear_raw
    email_log = EmailLog.find_by(id: params[:id])
    return render json: { error: 'Not found' }, status: 404 unless email_log

    email_log.update!(
      raw_data: nil
    )

    render json: { success: true }
  end
end
