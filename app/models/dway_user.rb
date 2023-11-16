class DwayUser < ApplicationRecord
  has_many :requests,    dependent: :nullify
  has_many :submissions, dependent: :nullify

  before_create do |user|
    user.api_token ||= "ddbj_repository_#{Base62.encode(SecureRandom.random_number(2 ** 256))}"
  end
end
