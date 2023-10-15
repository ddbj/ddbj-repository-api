class SubmitJob < ApplicationJob
  def perform(request)
    DdbjValidator.validate request

    return unless request.status == 'valid'

    submission = ActiveRecord::Base.transaction {
      request.update! status: 'submitted'

      request.dway_user.submissions.create!(request:)
    }

    request.write_files to: submission.dir
  end
end
