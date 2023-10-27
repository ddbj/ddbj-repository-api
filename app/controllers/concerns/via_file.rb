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
      request   = dway_user.requests.create!(db: db[:id], status: 'waiting')
      user_home = Pathname.new(ENV.fetch('USER_HOME_DIR')).join(dway_user.uid).cleanpath

      request.objs.create! _id: '_base'

      db[:objects].each do |obj|
        id = obj[:id]

        # TODO cardinality
        case obj[:optional] ? params[id] : params.require(id)
        in ActionDispatch::Http::UploadedFile => file
          request.objs.create! _id: id, file: file
        in %r(\A~/.) => relative_path
          path = user_home.join(relative_path.delete_prefix('~/')).cleanpath

          raise Error, "path must be in #{user_home}" unless path.to_s.start_with?(user_home.to_s)

          request.objs.create! _id: id, file: {
            io:       path.open,
            filename: path.basename
          }
        in nil
          next
        in unknown
          raise Error, "unexpected parameter format in #{id}: #{unknown.inspect}"
        end
      end

      request
    }
  end
end
