class Request < ApplicationRecord
  belongs_to :dway_user,  optional: true
  belongs_to :submission, optional: true

  has_many :objs, dependent: :destroy do
    def base
      find { _1._id == '_base' }
    end
  end

  validates :db,     inclusion: {in: DB.map { _1[:id] }}
  validates :status, inclusion: {in: %w(waiting processing finished)}

  def validity
    return nil unless status == 'finished'

    validities = Set.new(objs.pluck(:validity))

    if validities.include?('error')
      'error'
    elsif validities.include?('invalid')
      'invalid'
    else
      'valid'
    end
  end

  def validation_reports
    objs.map(&:validation_report)
  end

  def write_files(to:)
    to.tap(&:mkpath).join('validation-report.json').write JSON.pretty_generate(validation_reports)

    objs.each do |obj|
      obj_dir = to.join(obj._id).then { obj.destination.present? ? _1.join(obj.destination) : _1 }.tap(&:mkpath)

      if obj.file.attached?
        filename = obj.file.filename.sanitized

        obj_dir.join("#{filename}-validation-report.json").write JSON.pretty_generate(obj.validation_report)

        obj.file.open do |file|
          FileUtils.mv file.path, obj_dir.join(filename)
        end
      else
        obj_dir.join('validation-report.json').write JSON.pretty_generate(obj.validation_report)
      end
    end
  end
end
