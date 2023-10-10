class SubmitViaUserHomePathController < ApplicationController
  def create
    request = nil
    paths = nil

    ActiveRecord::Base.transaction do
      request = dway_user.requests.create!(status: 'processing')
      db      = params.require(:db)
      user_home = Pathname.new(ENV.fetch('USER_HOME_DIR').gsub('{user}', dway_user.uid))

      paths = DB_TO_OBJ_IDS_ASSOC.fetch(db).map {|obj_id|
        obj_dir = request.dir.join(obj_id).tap(&:mkpath)

        # TODO cardinality
        path = user_home.join(params.require(obj_id))
        raise ArgumentError unless path.expand_path.to_s.start_with?(user_home.expand_path.to_s)

        [obj_id, path.to_s]
      }.to_h
    end

    SubmitJob.perform_later request, paths

    render json: {
      request_id: request.id
    }, status: :created
  end
end
