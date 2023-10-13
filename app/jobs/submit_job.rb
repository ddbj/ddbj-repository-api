class SubmitJob < ApplicationJob
  def perform(request, paths)
    paths.each do |obj_id, path|
      FileUtils.cp path, request.dir.join(obj_id).tap(&:mkpath)
    end

    db = DB.find { _1[:id] == request.db }

    res = validator.post('validation', db[:objects].filter_map {|obj|
      next nil unless param = obj[:validator_param]

      path = paths.fetch(obj[:id])
      part = Faraday::Multipart::FilePart.new(path, 'application/octet-stream')

      [param, part]
    }.to_h)

    status, uuid = res.body.fetch_values(:status, :uuid)

    raise status if status == 'error'

    poll_status uuid do |validated, result|
      if validated && result.fetch(:validity)
        ActiveRecord::Base.transaction do
          submission = request.dway_user.submissions.create!

          submission.dir.dirname.mkpath
          FileUtils.mv request.dir, submission.dir

          request.update! status: 'succeeded', result:, submission:
        end
      else
        request.update! status: 'failed', result:
      end
    end
  end

  private

  def poll_status(uuid, &block)
    res = validator.get("validation/#{uuid}/status")

    case res.body.fetch(:status)
    when 'accepted', 'running'
      sleep 1 unless Rails.env.test?
      poll_status uuid, &block
    when 'finished'
      result = validator.get("validation/#{uuid}")

      block.call true, result.body.fetch(:result)
    when 'error'
      block.call false, message: result.body.fetch(:message)
    else
      raise 'must not happen'
    end
  end

  def validator
    Faraday.new(url: ENV.fetch('VALIDATOR_URL')) {|f|
      f.request :multipart
      f.response :raise_error
      f.response :json, parser_options: {symbolize_names: true}
    }
  end
end
