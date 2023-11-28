using PathnameContain

module ViaFile
  extend ActiveSupport::Concern

  class Error < StandardError; end

  included do
    rescue_from Error do |e|
      render json: {
        error: e.message
      }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: {
        error: e.message
      }, status: :unprocessable_entity
    end
  end

  def create_request_from_params(params, user)
    ActiveRecord::Base.transaction {
      db      = DB.find { _1[:id].downcase == params.require(:db) }
      request = user.requests.create!(db: db[:id], status: 'waiting')

      request.objs.create! _id: '_base'

      db[:objects].each do |obj|
        obj => {id:}
        val = obj[:optional] ? params[id] : params.require(id)

        handle_param user, request, obj, val
      end

      request
    }
  end

  private

  def handle_param(user, request, obj, val)
    obj => {id:}

    case val
    in {file:, **rest}
      request.objs.create! _id: id, file: file, **rest.slice(:destination)
    in {path: relative_path, **rest}
      user_home = Pathname.new(ENV.fetch('USER_HOME_DIR')).join(user.uid)
      path      = user_home.join(relative_path)

      raise Error, "path must be in #{user_home}" unless user_home.contain?(path)

      destination = rest[:destination]

      if path.directory?
        path.glob('**/*').reject(&:directory?).each do |fpath|
          relative_fpath = fpath.relative_path_from(path)

          request.objs.create! **{
            _id: id,

            file: {
              io:       fpath.open,
              filename: fpath.basename,
            },

            destination: [
              destination,
              relative_fpath.dirname.to_s
            ].reject { _1.blank? || _1 == '.' }.join('/').presence
          }
        end
      else
        request.objs.create! **{
          _id: id,

          file: {
            io:       path.open,
            filename: path.basename,
          },

          destination:
        }
      end
    in ActionController::Parameters
      handle_param user, request, obj, val.permit(:file, :path, :destination).to_hash.symbolize_keys
    in Array if obj[:multiple]
      val.each do |v|
        handle_param user, request, obj, v
      end
    in nil if obj[:optional]
      # do nothing
    in unknown
      raise Error, "unexpected parameter format in #{id}: #{unknown.inspect}"
    end
  end
end
