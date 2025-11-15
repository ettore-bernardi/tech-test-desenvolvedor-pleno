# frozen_string_literal: true

class Customer < ApplicationRecord
  validates :name, :email, presence: true
end
