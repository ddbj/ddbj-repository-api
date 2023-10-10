class SubmitJob < ApplicationJob
  def perform(request, paths)
    paths.each do |k, v|
      FileUtils.cp v, request.dir.join(k)
    end

    ActiveRecord::Base.transaction do
      submission = request.dway_user.submissions.create!

      submission.dir.dirname.mkpath
      FileUtils.mv request.dir, submission.dir

      request.update! status: 'succeeded', submission:
    end
  end
end
