class DdbjValidator
  include Singleton

  class << self
    delegate :validate, to: :instance
  end

  def initialize
    @client = Faraday.new(url: ENV.fetch('VALIDATOR_URL')) {|f|
      f.request :multipart
      f.response :logger unless Rails.env.test?
      f.response :json, parser_options: {symbolize_names: true}
    }
  end

  def validate(request)
    db   = DB.find { _1[:id] == request.db }
    objs = db[:objects].select { _1[:validator] == 'ddbj_validator' }

    if objs.empty?
      request.update! status: 'valid'
      return
    end

    res = Dir.mktmpdir {|tmpdir|
      tmpdir = Pathname.new(tmpdir)

      @client.post('validation', objs.map {|obj|
        obj  = request.objs.find { _1.key == obj[:id] }
        path = tmpdir.join(obj.file.filename.sanitized)

        obj.file.open do |file|
          FileUtils.mv file.path, path
        end

        part = Faraday::Multipart::FilePart.new(path.to_s, 'application/octet-stream')

        [obj[:param_name], part]
      }.to_h)
    }

    case res.body
    in {status: 'error', message:}
      request.update! status: 'error', result: {error: message}
    in {uuid:}
      validated, result = wait_for_finish(uuid)

      status = if validated
                 result.fetch(:validity) ? 'valid' : 'invalid'
               else
                 'error'
               end

      request.update! status: status, result: result
    else
      raise 'must not happen'
    end
  end

  private

  def wait_for_finish(uuid)
    res = @client.get("validation/#{uuid}/status")

    case res.body.fetch(:status)
    when 'accepted', 'running'
      sleep 1 unless Rails.env.test?

      wait_for_finish(uuid)
    when 'finished'
      detail = @client.get("validation/#{uuid}")

      [true, detail.body.fetch(:result)]
    when 'error'
      detail = @client.get("validation/#{uuid}")

      [false, error: detail.body.fetch(:message)]
    else
      raise "must not happen: #{res.body.to_json}"
    end
  end
end
