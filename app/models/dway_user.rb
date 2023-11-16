class DwayUser < ApplicationRecord
  has_many :requests,    dependent: :nullify
  has_many :submissions, dependent: :nullify

  before_create do |user|
    user.api_token ||= SecureRandom.urlsafe_base64(32)
  end
end
