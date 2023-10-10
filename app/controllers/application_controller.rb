class ApplicationController < ActionController::API
  DB_TO_OBJ_IDS_ASSOC = {
    bioproject: %w(BioProject Submission),
    biosample:  %w(BioSample Submission),
    trad:       %w(Sequence Annotation),
    dra:        %w(Submission Experiment Run RunFile Analysis AnalysisFile),
    gea:        %w(IDF SDRF ADF RawDataFile ProcessedDataFile),
    metabobank: %w(IDF SDRF MAF RawDataFile ProcessedDataFile),
    jvar:       %w(Study SampleSet Sample Experiment Assay VariantCallSV VariantRegionSV VariantCallFile),
  }.stringify_keys

  private

  def dway_user
    uid = request.headers['X-Dway-User-ID']

    DwayUser.find_or_create_by!(uid:)
  end
end
