class SubmitViaUserHomePathController < ApplicationController
  def create
    request = nil
    paths   = nil

    ActiveRecord::Base.transaction do
      db        = DB.find { _1[:id].downcase == params.require(:db) }
      request   = dway_user.requests.create!(db: db[:id], status: 'processing')
      user_home = Pathname.new(ENV.fetch('USER_HOME_DIR').gsub('{user}', dway_user.uid))

      paths = db[:objects].map {|obj|
        # TODO cardinality
        path = user_home.join(params.require(obj[:id]))

        raise ArgumentError unless path.expand_path.to_s.start_with?(user_home.expand_path.to_s)

        [obj[:id], path.to_s]
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
