# frozen_string_literal: true

class EmailLog < ApplicationRecord # rubocop:disable Style/Documentation
  belongs_to :upload, optional: true, foreign_key: :upload_id

  validates :status, presence: true
end
