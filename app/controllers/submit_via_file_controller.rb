class SubmitViaFileController < ApplicationController
  def create
    request = nil
    paths   = nil

    ActiveRecord::Base.transaction do
      db        = DB.find { _1[:id].downcase == params.require(:db) }
      request   = dway_user.requests.create!(db: db[:id], status: 'processing')
      tmpdir    = Pathname.new(Dir.mktmpdir)
      user_home = Pathname.new(ENV.fetch('USER_HOME_DIR').gsub('{user}', dway_user.uid)).expand_path

      paths = db[:objects].map {|obj|
        # TODO cardinality
        case params.require(obj[:id])
        in ActionDispatch::Http::UploadedFile => file
          dest = tmpdir.join(file.original_filename)

          FileUtils.mv file.path, dest

          [obj[:id], dest.to_s]
        in String => path
          abs = user_home.join(path)

          raise ArgumentError unless abs.expand_path.to_s.start_with?(user_home.to_s)

          [obj[:id], abs.to_s]
        else
          raise 'must not happen'
        end
      }.to_h
    end

    SubmitJob.perform_later request, paths

    render json: {
      request: {
        id:  request.id,
        url: url_for(request)
      }
    }, status: :created
  end
end
