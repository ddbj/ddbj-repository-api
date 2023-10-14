class SubmitJob < ApplicationJob
  def perform(request)
    DdbjValidator.validate request do
      submission = request.dway_user.submissions.create!(request:)

      FileUtils.mv request.dir, submission.dir.tap { _1.dirname.mkpath }
    end
  end
end
