class Submission < ApplicationRecord
  belongs_to :request

  after_destroy do |submission|
    submission.dir.rmtree
  end

  def public_id
    id ? "X-#{id}" : nil
  end

  def dir
    Pathname.new(ENV.fetch('REPOSITORY_DIR')).join(request.user.uid, 'submissions', public_id)
  end
end
