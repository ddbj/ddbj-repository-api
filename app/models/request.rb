class Request < ApplicationRecord
  belongs_to :dway_user

  has_one :submission

  enum :status, %i(processing succeeded failed)

  def dir
    Pathname.new(ENV.fetch('REPOSITORY_DIR')).join(dway_user.uid, 'requests', id.to_s)
  end
end
