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
end
