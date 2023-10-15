class ValidateJob < ApplicationJob
  def perform(request)
    DdbjValidator.validate request

    request.write_files to: request.dir
  end
end
