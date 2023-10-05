class DwayUser < ApplicationRecord
  has_many :requests,    dependent: :destroy
  has_many :submissions, dependent: :destroy
end
