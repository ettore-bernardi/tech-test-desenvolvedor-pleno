# frozen_string_literal: true

# config/routes.rb
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  root to: 'uploads#new'
  resources :uploads, only: %i[index new create show] do
    member do
      get :logs_json
    end
  end
  resources :customers, only: %i[index show]
  resources :logs, only: %i[index show]
  get 'email_logs/:id/raw', to: 'email_logs#raw', as: :email_log_raw
  patch 'email_logs/:id/clear_raw', to: 'email_logs#clear_raw', as: :email_log_clear_raw
  patch 'uploads/:id/clear_email_logs_raw', to: 'uploads#clear_email_logs_raw', as: :clear_upload_email_logs_raw
end
