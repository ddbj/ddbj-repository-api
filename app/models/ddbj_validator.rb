class DdbjValidator
  include Singleton

  class << self
    delegate :validate, to: :instance
  end

  def initialize
    @client = Faraday.new(url: ENV.fetch('VALIDATOR_URL')) {|f|
      f.request :multipart
      f.response :raise_error
      f.response :json, parser_options: {symbolize_names: true}
    }
  end

  def validate(request, &on_success)
    request.paths.each do |obj_id, path|
      FileUtils.cp path, request.dir.join(obj_id).tap(&:mkpath)
    end

    db = DB.find { _1[:id] == request.db }

    res = @client.post('validation', db[:objects].filter_map {|obj|
      next nil unless param = obj[:validator_param]

      path = request.paths.fetch(obj[:id])
      part = Faraday::Multipart::FilePart.new(path, 'application/octet-stream')

      [param, part]
    }.to_h)

    status, uuid = res.body.fetch_values(:status, :uuid)

    raise status if status == 'error'

    poll_status uuid do |validated, result|
      request.dir.join('validation-report.json').write JSON.pretty_generate(result)

      if validated && result.fetch(:validity)
        ActiveRecord::Base.transaction do
          request.update! status: 'succeeded', result: result

          on_success&.call
        end
      else
        request.update! status: 'failed', result: result
      end
    end
  end

  private

  def poll_status(uuid, &done)
    res = @client.get("validation/#{uuid}/status")

    case res.body.fetch(:status)
    when 'accepted', 'running'
      sleep 1 unless Rails.env.test?
      poll_status uuid, &done
    when 'finished'
      result = @client.get("validation/#{uuid}")

      done.call true, result.body.fetch(:result)
    when 'error'
      done.call false, error: result.body.fetch(:message)
    else
      raise 'must not happen'
    end
  end
end
