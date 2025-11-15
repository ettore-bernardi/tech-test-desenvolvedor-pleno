# frozen_string_literal: true

class EmailLog < ApplicationRecord
  belongs_to :upload, optional: true, foreign_key: :upload_id

  validates :status, presence: true
end
