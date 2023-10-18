class DdbjValidator
  def validate(obj, meta)
    res = Dir.mktmpdir {|tmpdir|
      tmpdir = Pathname.new(tmpdir)
      path   = tmpdir.join(obj.file.filename.sanitized)

      obj.file.open do |file|
        FileUtils.mv file.path, path
      end

      part = Faraday::Multipart::FilePart.new(path.to_s, 'application/octet-stream')

      client.post('validation', meta[:param_name] => part)
    }

    validated, details = wait_for_finish(res.body.fetch(:uuid))

    validity = if validated
                 details.fetch(:validity) ? 'valid' : 'invalid'
               else
                 'error'
               end

    obj.update! validity: validity, validation_details: details
  rescue => e
    obj.update! validity: 'error', validation_details: {error: e.message}

    Rails.logger.error e
  end

  private

  def client
    @client ||= Faraday.new(url: ENV.fetch('VALIDATOR_URL')) {|f|
      f.request :multipart

      f.response :json, parser_options: {symbolize_names: true}
      f.response :logger unless Rails.env.test?
    }
  end

  def wait_for_finish(uuid)
    res = client.get("validation/#{uuid}/status")

    case res.body.fetch(:status)
    when 'accepted', 'running'
      sleep 1 unless Rails.env.test?

      wait_for_finish(uuid)
    when 'finished'
      detail = client.get("validation/#{uuid}")

      [true, detail.body.fetch(:result)]
    when 'error'
      detail = client.get("validation/#{uuid}")

      [false, error: detail.body.fetch(:message)]
    else
      raise "must not happen: #{res.body.to_json}"
    end
  end
end
