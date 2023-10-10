class SubmitViaUploadController < ApplicationController
  def create
    request = nil
    paths = nil

    ActiveRecord::Base.transaction do
      request = dway_user.requests.create!(status: 'processing')
      db      = params.require(:db)
      tmpdir  = Pathname.new(Dir.mktmpdir)

      paths = DB_TO_OBJ_IDS_ASSOC.fetch(db).map {|obj_id|
        # TODO cardinality
        file = params.require(obj_id)
        dest = tmpdir.join(file.original_filename)

        FileUtils.mv file.path, dest

        [obj_id, dest.to_s]
      }.to_h
    end

    SubmitJob.perform_later request, paths

    render json: {
      request_id: request.id
    }, status: :created
  end
end
