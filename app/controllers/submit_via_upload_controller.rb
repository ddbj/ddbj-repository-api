class SubmitViaUploadController < ApplicationController
  def create
    request = nil
    paths   = nil

    ActiveRecord::Base.transaction do
      db      = params.require(:db)
      request = dway_user.requests.create!(db:, status: 'processing')
      tmpdir  = Pathname.new(Dir.mktmpdir)

      paths = DB.find { _1[:id].downcase == db }[:objects].map {|obj|
        # TODO cardinality
        file = params.require(obj[:id])
        dest = tmpdir.join(file.original_filename)

        FileUtils.mv file.path, dest

        [obj[:id], dest.to_s]
      }.to_h
    end

    SubmitJob.perform_later request, paths

    render json: {
      request_id: request.id
    }, status: :created
  end
end
