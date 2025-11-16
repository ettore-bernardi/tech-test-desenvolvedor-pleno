# frozen_string_literal: true

class Customer < ApplicationRecord # rubocop:disable Style/Documentation
  validates :name, :email, presence: true
end
