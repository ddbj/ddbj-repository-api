class SubmitViaUploadController < ApplicationController
  def create
    request = nil
    paths   = nil

    ActiveRecord::Base.transaction do
      db      = DB.find { _1[:id].downcase == params.require(:db) }
      request = dway_user.requests.create!(db: db[:id], status: 'processing')
      tmpdir  = Pathname.new(Dir.mktmpdir)

      paths = db[:objects].map {|obj|
        # TODO cardinality
        file = params.require(obj[:id])
        dest = tmpdir.join(file.original_filename)

        FileUtils.mv file.path, dest

        [obj[:id], dest.to_s]
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
