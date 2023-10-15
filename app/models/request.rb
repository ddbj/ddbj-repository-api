class Request < ApplicationRecord
  belongs_to :dway_user,  optional: true
  belongs_to :submission, optional: true

  has_many :objs, dependent: :destroy

  enum :status, %i(processing succeeded failed)

  after_destroy do |request|
    request.dir.rmtree
  end

  def dir
    Pathname.new(ENV.fetch('REPOSITORY_DIR')).join(dway_user.uid, 'requests', id.to_s)
  end

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
