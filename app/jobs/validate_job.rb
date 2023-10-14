class ValidateJob < ApplicationJob
  def perform(request)
    DdbjValidator.validate request
  end
end
