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
      db      = DB.find { _1[:id].downcase == params.require(:db) }
      request = dway_user.requests.create!(db: db[:id], status: 'waiting')

      request.objs.create! _id: '_base'

      db[:objects].each do |obj|
        id  = obj[:id]
        val = obj[:optional] ? params[id] : params.require(id)

        handle_param request, obj, val
      end

      request
    }
  end

  private

  def handle_param(request, obj, val)
    id, optional, multiple = obj.values_at(:id, :optional, :multiple)

    case val
    in ActionDispatch::Http::UploadedFile => file
      request.objs.create! _id: id, file: file
    in %r(\A~/.) => relative_path
      user_home = Pathname.new(ENV.fetch('USER_HOME_DIR')).join(dway_user.uid).cleanpath
      path      = user_home.join(relative_path.delete_prefix('~/')).cleanpath

      raise Error, "path must be in #{user_home}" unless path.to_s.start_with?(user_home.to_s)

      request.objs.create! _id: id, file: {
        io:       path.open,
        filename: path.basename
      }
    in nil if optional
      # do nothing
    in Array => vals if multiple
      vals.each do |val|
        handle_param request, obj, val
      end
    in unknown
      raise Error, "unexpected parameter format in #{id}: #{unknown.inspect}"
    end
  end
end
