class MetabobankValidator
  def validate(request)
    objs = request.objs.index_by(&:_id)

    request.write_files_to_tmp do |tmpdir|
      Dir.chdir tmpdir do
        idf, sdrf = objs.fetch_values('IDF', 'SDRF').map(&:path)

        cmd = %W(bundle exec mb-validate --machine-readable -i #{idf} -s #{sdrf}).then {
          if bs = objs['BioSample']
            _1 + %W(-t #{bs.file.filename.sanitized})
          else
            _1
          end
        }

        out, status = Open3.capture2e({
          'BUNDLE_GEMFILE' => Rails.root.join('Gemfile').to_s
        }, *cmd)

        raise out unless status.success?

        errors = JSON.parse(out, symbolize_names: true).group_by { _1.fetch(:object_id) }

        objs.each do |obj_id, obj|
          if errs = errors[obj_id]
            validity = if errs.any? { _1[:severity] == 'error' }
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
