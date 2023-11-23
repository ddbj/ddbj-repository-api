class Obj < ApplicationRecord
  belongs_to :request

  has_one_attached :file

  scope :without_base, -> { where.not(_id: '_base') }

  validates :validity, inclusion: {in: %w(valid invalid error)}, allow_nil: true

  def path
    base? ? nil : [destination, file.filename.sanitized].reject(&:blank?).join('/')
  end

  def base?
    _id == '_base'
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
