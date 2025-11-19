class ProcessingLog < ApplicationRecord
  belongs_to :customer, optional: true
  has_one_attached :raw_file
end
