class MetabobankValidator
  def validate(request)
    objs = request.objs.index_by(&:_id)

    Dir.mktmpdir do |tmpdir|
      tmpdir = Pathname.new(tmpdir)

      objs.values.each do |obj|
        next unless obj

        obj.file.open do |file|
          FileUtils.mv file.path, tmpdir.join(obj.file.filename.sanitized)
        end
      end

      Dir.chdir tmpdir do
        env = {
          'BUNDLE_GEMFILE' => Rails.root.join('Gemfile').to_s
        }

        out, status = Open3.capture2e(env, "bundle exec mb-validate -i #{objs.fetch('IDF').file.filename.sanitized} -s #{objs.fetch('SDRF').file.filename.sanitized} --machine-readable")

        raise out unless status.success?

        errors = JSON.parse(out, symbolize_names: true).group_by { _1.fetch(:object_id) }

        objs.each do |obj_id, obj|
          if errs = errors[obj_id]
            validity = if errs.any? { _1[:severity] == 'error' || _1[:severity] == 'error_ignore' }
                         'invalid'
                       else
                         'valid'
                       end

            obj.update! validity:, validation_details: errs
          else
            obj.update! validity: 'valid'
          end
        end
      end
    end
  end
end