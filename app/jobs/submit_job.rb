class SubmitJob < ApplicationJob
  def perform(request)
    request.update! status: 'processing'

    DdbjValidator.validate request

    return unless request.validity == 'valid'

    submission = request.dway_user.submissions.create!(request:)

    request.write_files to: submission.dir
  ensure
    request.update! status: 'finished'
  end
end
