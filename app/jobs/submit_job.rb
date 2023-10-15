class SubmitJob < ApplicationJob
  def perform(request)
    DdbjValidator.validate request

    if request.status == 'succeeded'
      submission = request.dway_user.submissions.create!(request:)

      request.write_files to: submission.dir
    end
  end
end
