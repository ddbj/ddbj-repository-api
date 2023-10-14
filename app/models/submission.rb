class Submission < ApplicationRecord
  belongs_to :dway_user
  belongs_to :request

  def public_id
    id ? "X-#{id}" : nil
  end

  def dir
    Pathname.new(ENV.fetch('REPOSITORY_DIR')).join(dway_user.uid, 'submissions', public_id)
  end
end
