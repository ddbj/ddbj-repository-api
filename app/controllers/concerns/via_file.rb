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
    ActiveRecord::Base.transaction {
      db        = DB.find { _1[:id].downcase == params.require(:db) }
      request   = dway_user.requests.create!(db: db[:id], status: 'processing')
      user_home = Pathname.new(ENV.fetch('USER_HOME_DIR')).join(dway_user.uid).expand_path

      db[:objects].each do |obj|
        key = obj[:id]

        # TODO cardinality
        case params.require(key)
        in ActionDispatch::Http::UploadedFile => file
          request.objs.create! key: key, file: file
        in %r(\A~/.) => path
          abs = user_home.join(path.delete_prefix('~/')).expand_path

          raise Error, "path must be in #{user_home}" unless abs.to_s.start_with?(user_home.to_s)

          request.objs.create! key: key, file: {
            io:       abs.open,
            filename: abs.basename
          }
        in unknown
          raise Error, "unexpected parameter format in #{key}: #{unknown.inspect}"
        end
      end

      request
    }
  end
end
