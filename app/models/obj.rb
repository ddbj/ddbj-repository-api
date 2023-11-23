class Obj < ApplicationRecord
  belongs_to :request

  has_one_attached :file

  validates :validity, inclusion: {in: %w(valid invalid error)}, allow_nil: true

  def path
    file.attached? ? [destination, file.filename.sanitized].reject(&:blank?).join('/') : nil
  end

  def validation_report
    {
      object_id: _id,
      path:      path,
      validity:  validity,
      details:   validation_details
    }
  end
end
