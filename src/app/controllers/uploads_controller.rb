# frozen_string_literal: true

class UploadsController < ApplicationController
  def index
    @logs = EmailLog.order(created_at: :desc).limit(100)
  end

  def new
    @uploads = Upload.order(created_at: :desc).limit(50)
  end

  def create
    files = params[:eml_files]

    redirect_to new_upload_path, alert: 'Escolha ao menos um arquivo .eml' and return unless files.present?

    upload = Upload.create!(files_count: 0, status: 'processing')

    saved_ids = []

    files.each do |file|
      raw_bytes = file.read
      raw_utf8 = safe_convert_to_utf8(raw_bytes)

      email_log = EmailLog.create!(
        upload_id: upload.id,
        file_name: file.original_filename,
        raw_data: raw_utf8,
        status: 'pending'
      )
      saved_ids << email_log.id
    end

    upload.update!(files_count: saved_ids.size)
    ProcessUploadJob.perform_later(upload.id)

    redirect_to upload_path(upload), notice: "#{saved_ids.size} arquivo(s) enviados."
  end

  def show
    @upload = Upload.find(params[:id])
    @logs = @upload.email_logs.order(created_at: :desc)
  end

  def logs_json
    @upload = Upload.find(params[:id])
    @logs = @upload.email_logs.order(created_at: :desc)

    render json: {
      logs: @logs.map do |log|
        {
          id: log.id,
          status: log.status,
          file_name: log&.file_name,
          message: log.message,
          parsed_json: log.parsed_json || {},
          created_at: log.created_at.strftime('%d/%m/%Y %H:%M:%S')
        }
      end,
      upload_status: @upload.status,
      total_files: @upload.files_count,
      processed_files: @logs.count
    }
  end

  def clear_email_logs_raw
    upload = Upload.find_by(id: params[:id])
    return render json: { success: false, error: 'Upload not found' }, status: :not_found unless upload

    begin
      upload.email_logs.update_all(raw_data: nil, message: nil, parsed_json: {})

      render json: { success: true, cleared: upload.email_logs.count }
    rescue StandardError => e
      Rails.logger.error("[UploadsController#clear_email_logs_raw] upload=#{upload.id} error: #{e.class}: #{e.message}")
      render json: { success: false, error: e.message }, status: :internal_server_error
    end
  end

  private

  def safe_convert_to_utf8(raw)
    begin
      require 'charlock_holmes'
      detection = CharlockHolmes::EncodingDetector.detect(raw)
      return CharlockHolmes::Converter.convert(raw, detection[:encoding], 'UTF-8') if detection && detection[:encoding]
    rescue LoadError
    rescue StandardError => e
      Rails.logger.warn("[UploadsController] charlock error: #{e.class}: #{e.message}")
    end

    encode_with_heuristics(raw)
  end

  def encode_with_heuristics(raw)
    return raw if raw.encoding == Encoding::UTF_8 && raw.valid_encoding?

    bin = raw.dup.force_encoding('BINARY')

    begin
      utf8 = bin.encode('UTF-8')
      return utf8 if utf8.valid_encoding?
    rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
    end

    begin
      iso = raw.dup.force_encoding('ISO-8859-1')
      utf8_from_iso = iso.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      return utf8_from_iso if utf8_from_iso.valid_encoding?
    rescue StandardError => _e
    end

    raw.dup.force_encoding('BINARY').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end
