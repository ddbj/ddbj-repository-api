class SubmitJob < ApplicationJob
  def perform(request)
    ActiveRecord::Base.transaction do
      submission = request.dway_user.submissions.create!

      submission.dir.dirname.mkpath
      FileUtils.mv request.dir, submission.dir

      request.update! status: 'succeeded', submission:
    end
  end
end
