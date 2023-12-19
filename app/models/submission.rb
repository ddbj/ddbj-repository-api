class Submission < ApplicationRecord
  belongs_to :user, optional: true

  has_one :request

  after_destroy do |submission|
    submission.dir.rmtree
  end

  def public_id
    id ? "X-#{id}" : nil
  end

  def dir
    Pathname.new(ENV.fetch('REPOSITORY_DIR')).join(user.uid, 'submissions', public_id)
  end
end
