class Obj < ApplicationRecord
  belongs_to :request

  has_one_attached :file

  validates :validity, inclusion: {in: %w(valid invalid error)}, allow_nil: true

  def validation_report
    {
      validator: validator,
      validity:  validity,
      details:   validation_details
    }
  end
end
