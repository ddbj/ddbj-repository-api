module ViaFile
  extend ActiveSupport::Concern

  class Error < StandardError; end

  included do
    rescue_from Error do |e|
      render json: {
        error: e.message
      }, status: :bad_request
    end
  end

  def create_request_from_params
    db        = DB.find { _1[:id].downcase == params.require(:db) }
    tmpdir    = Pathname.new(Dir.mktmpdir)
    user_home = Pathname.new(ENV.fetch('USER_HOME_DIR')).join(dway_user.uid).expand_path

    paths = db[:objects].map {|obj|
      # TODO cardinality
      case params.require(obj[:id])
      in ActionDispatch::Http::UploadedFile => file
        dest = tmpdir.join(file.original_filename)

        FileUtils.mv file.path, dest

        [obj[:id], dest.to_s]
      in %r(\A~/.) => path
        abs = user_home.join(path.delete_prefix('~/'))

        raise Error, "path must be in #{user_home}" unless abs.expand_path.to_s.start_with?(user_home.to_s)

        [obj[:id], abs.to_s]
      in unknown
        raise Error, "unexpected parameter format in #{obj[:id]}: #{unknown.inspect}"
      end
    }.to_h

    dway_user.requests.create!(db: db[:id], paths:, status: 'processing')
  end
end
