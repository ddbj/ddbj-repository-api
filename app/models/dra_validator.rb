class DraValidator
  OBJ_IDS = %w(Submission Experiment Run Analysis)

  def validate(request)
    objs = request.objs.index_by(&:key).slice(*OBJ_IDS)

    Dir.mktmpdir do |tmpdir|
      tmpdir = Pathname.new(tmpdir)

      objs.values.each do |obj|
        next unless obj

        obj.file.open do |file|
          FileUtils.mv file.path, tmpdir.join("example-0001_dra_#{obj.key}.xml")
        end
      end

      Dir.chdir tmpdir do
        env = {
          'BUNDLE_GEMFILE' => Rails.root.join('Gemfile').to_s
        }

        out, status = Open3.capture2e(env, 'bundle exec validate_meta_dra -a example -i 0001 --machine-readable')

        raise out unless status.success?

        errors = JSON.parse(out, symbolize_names: true).group_by { _1.fetch(:object_id) }

        OBJ_IDS.each do |obj_id|
          next unless obj = request.objs.find_by(key: obj_id)

          if errs = errors[obj_id]
            obj.update! validity: 'invalid', validation_details: errs
          else
            obj.update! validity: 'valid'
          end
        end
      end
    end
  end
end
