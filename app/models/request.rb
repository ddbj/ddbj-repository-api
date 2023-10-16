class Request < ApplicationRecord
  belongs_to :dway_user,  optional: true
  belongs_to :submission, optional: true

  has_many :objs, dependent: :destroy

  validates :db,     inclusion: {in: DB.map { _1[:id] }}
  validates :status, inclusion: {in: %w(processing valid invalid error submitted)}

  def write_files(to:)
    to.tap(&:mkpath).join('validation-report.json').write JSON.pretty_generate(result)

    objs.each do |obj|
      obj.file.open do |file|
        dest = to.join(obj.key).tap(&:mkpath).join(obj.file.filename.sanitized)

        FileUtils.mv file.path, dest
      end
    end
  end
end
