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

    case res.body
    in {status: 'error', message:}
      request.update! status: 'error', result: {error: message}
    in {uuid:}
      validated, result = wait_for_finish(uuid)

      status = if validated && result.fetch(:validity)
                 'valid'
               elsif validated
                 'invalid'
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

    case res.body
    in {status: 'accepted' | 'running'}
      sleep 1 unless Rails.env.test?

      wait_for_finish(uuid)
    in {status: 'finished'}
      result = @client.get("validation/#{uuid}")

      [true, result.body.fetch(:result)]
    in {status: 'error', message:}
      [false, error: message]
    else
      raise 'must not happen'
    end
  end
end
