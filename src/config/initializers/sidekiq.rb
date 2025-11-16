# frozen_string_literal: true

# config/initializers/sidekiq.rb
# safe initializer para Rails 7

require 'yaml'
return unless defined?(Sidekiq) # sai cedo se a gem não estiver presente

# carrega sidekiq.yml com tolerância a formatos
raw = {}
begin
  raw = YAML.load_file(Rails.root.join('config', 'sidekiq.yml')) || {}
rescue StandardError => e
  Rails.logger.debug("sidekiq initializer: couldn't load sidekiq.yml: #{e.message}")
end

yaml_env = (raw[Rails.env] || raw).dup
yaml_env = yaml_env.transform_keys(&:to_sym) if yaml_env.respond_to?(:transform_keys)

# configurações que SÓ devem rodar no processo Sidekiq (workers)
if Sidekiq.server?
  Sidekiq.configure_server do |config|
    # filas (compatível com Sidekiq 7: config.queues = [...])
    if yaml_env && yaml_env[:queues]
      if config.respond_to?(:queues=)
        config.queues = yaml_env[:queues].map(&:to_s)
      else
        # fallback prudente para versões antigas/estranhas
        config.instance_variable_set(:@options,
                                     (config.instance_variable_get(:@options) || {}).merge(queues: yaml_env[:queues].map(&:to_s)))
      end
    end

    # ex: redis
    if ENV['REDIS_URL'].present?
      Sidekiq.configure_server do |c|
        c.redis = { url: ENV['REDIS_URL'] }
      end
    end

    # outros handlers do server (error handlers, lifecycle hooks) aqui...
  end
end

# configurações do client (web app) — segura para executar no rails server
Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] } if ENV['REDIS_URL'].present?
end
