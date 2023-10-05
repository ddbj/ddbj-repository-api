class Submission < ApplicationRecord
  belongs_to :dway_user

  has_many :requests

  def dir
    Pathname.new(ENV.fetch('REPOSITORY_DIR')).join(dway_user.uid, 'submissions', id.to_s)
  end
end
