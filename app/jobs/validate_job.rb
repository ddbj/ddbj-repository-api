class ValidateJob < ApplicationJob
  def perform(request)
    Validators.new(request).validate
  end
end
