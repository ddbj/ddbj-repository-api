class ValidateJob < ApplicationJob
  def perform(request)
    request.update! status: 'processing'

    DdbjValidator.validate request
  ensure
    request.update! status: 'finished'
  end
end
