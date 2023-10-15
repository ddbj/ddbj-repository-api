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

  def validate(request)
    db = DB.find { _1[:id] == request.db }

    res = Dir.mktmpdir {|tmpdir|
      tmpdir = Pathname.new(tmpdir)

      @client.post('validation', db[:objects].filter_map {|obj|
        next false unless param = obj[:validator_param]

        obj  = request.objs.find { _1.key == obj[:id] }
        path = tmpdir.join(obj.file.filename.sanitized)

        obj.file.open do |file|
          FileUtils.mv file.path, path
        end

        part = Faraday::Multipart::FilePart.new(path.to_s, 'application/octet-stream')

        [param, part]
      }.to_h)
    }

    status, uuid = res.body.fetch_values(:status, :uuid)

    raise status if status == 'error'

    wait_for_finish uuid do |validated, result|
      if validated && result.fetch(:validity)
        request.update! status: 'succeeded', result: result
      else
        request.update! status: 'failed', result: result
      end
    end
  end

  private

  def wait_for_finish(uuid, &done)
    res = @client.get("validation/#{uuid}/status")

    case res.body.fetch(:status)
    when 'accepted', 'running'
      sleep 1 unless Rails.env.test?
      wait_for_finish uuid, &done
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
