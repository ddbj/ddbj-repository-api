class MetabobankValidator
  def validate(request)
    obj_by_id = request.objs.index_by(&:_id)

    request.write_files_to_tmp do |tmpdir|
      Dir.chdir tmpdir do
        idf, sdrf = obj_by_id.fetch_values('IDF', 'SDRF').map(&:path)

        cmd = %W(bundle exec mb-validate --machine-readable -i #{idf} -s #{sdrf}).then {
          if bs = obj_by_id['BioSample']
            _1 + %W(-t #{bs.path})
          else
            _1
          end
        }.then {
          if obj_by_id.key?('MAF') || obj_by_id.key?('RawDataFile') || obj_by_id.key?('ProcessedDataFile')
            _1 + %w(-d)
          else
            _1
          end
        }

        out, status = Open3.capture2e({
          'BUNDLE_GEMFILE' => Rails.root.join('Gemfile').to_s
        }, *cmd)

        raise out unless status.success?

        errors = JSON.parse(out, symbolize_names: true).group_by { _1.fetch(:object_id) }

        request.objs.group_by(&:_id).each do |obj_id, objs|
          if errs = errors[obj_id]
            validity = if errs.any? { _1[:severity] == 'error' }
                         'invalid'
                       else
                         'valid'
                       end

            objs.each do |obj|
              obj.update! validity:, validation_details: errs
            end
          else
            objs.each do |obj|
              obj.update! validity: 'valid'
            end
          end
        end
      end
    end
  end
end
