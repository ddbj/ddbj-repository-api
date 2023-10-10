class SubmitJob < ApplicationJob
  def perform(request, paths)
    paths.each do |obj_id, path|
      FileUtils.cp path, request.dir.join(obj_id).tap(&:mkpath)
    end

    ActiveRecord::Base.transaction do
      submission = request.dway_user.submissions.create!

      submission.dir.dirname.mkpath
      FileUtils.mv request.dir, submission.dir

      request.update! status: 'succeeded', submission:
    end
  end
end
