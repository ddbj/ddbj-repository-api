class SubmitJob < ApplicationJob
  def perform(request)
    Validators.new(request).validate do
      next unless request.validity == 'valid'

      submission = request.user.submissions.create!(request:)

      request.write_submission_files to: submission.dir
    end
  end
end
