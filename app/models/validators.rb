class Validators
  VALIDATOR = {
    bioproject: DdbjValidator.new(obj_id: 'BioProject'),
    biosample:  DdbjValidator.new(obj_id: 'BioSample'),
    dra:        DraValidator.new,
    metabobank: MetabobankValidator.new
  }.stringify_keys

  def initialize(request)
    @request = request
  end

  def validate(&on_finish)
    begin
      @request.update! status: 'processing'

      db = DB.find { _1[:id] == @request.db }
      db => {validator:}

      begin
        VALIDATOR.fetch(validator).validate @request
      rescue => e
        @request.objs.base.update! validity: 'error', validation_details: {error: e.message}

        Rails.logger.error e
      end
    ensure
      @request.update! status: 'finished'
    end

    on_finish&.call
  end
end
