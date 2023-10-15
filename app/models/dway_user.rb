class DwayUser < ApplicationRecord
  has_many :requests,    dependent: :nullify
  has_many :submissions, dependent: :nullify
end
