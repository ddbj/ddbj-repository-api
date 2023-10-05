class SubmitViaUploadController < ApplicationController
  DB_TO_OBJ_IDS_ASSOC = {
    bioproject: %w(BioProject Submission),
    biosample:  %w(BioSample Submission),
    trad:       %w(Sequence Annotation),
    dra:        %w(Submission Experiment Run RunFile Analysis AnalysisFile),
    gea:        %w(IDF SDRF ADF RawDataFile ProcessedDataFile),
    metabobank: %w(IDF SDRF MAF RawDataFile ProcessedDataFile),
    jvar:       %w(Study SampleSet Sample Experiment Assay VariantCallSV VariantRegionSV VariantCallFile),
  }.stringify_keys

  def create
    request = nil

    ActiveRecord::Base.transaction do
      request = dway_user.requests.create!(status: 'processing')
      db      = params.require(:db)

      DB_TO_OBJ_IDS_ASSOC.fetch(db).each do |obj_id|
        obj_dir = request.dir.join(obj_id).tap(&:mkpath)

        # TODO cardinality
        file = params.require(obj_id)

        FileUtils.mv file.path, obj_dir.join(file.original_filename)
      end
    end

    SubmitJob.perform_later request

    render json: {
      request_id: request.id
    }, status: :created
  end
end
