# frozen_string_literal: true

# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Compatibilidade: permite que código que chama perform_async continue funcionando
  # (delegando para perform_later do ActiveJob)
  class << self
    def perform_async(*args)
      perform_later(*args)
    end
  end
end
