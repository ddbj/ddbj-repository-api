class Obj < ApplicationRecord
  belongs_to :request

  has_one_attached :file
end
