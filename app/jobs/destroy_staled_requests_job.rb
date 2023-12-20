class DestroyStaledRequestsJob < ApplicationJob
  def perform
    Request.where.missing(:submission).where(created_at: ..1.year.ago).destroy_all
  end
end
