class Validators
  VALIDATOR = {
    ddbj:        DdbjValidator.new,
    dra:         DraValidator.new,
    metabobank:  MetabobankValidator.new,
    passthrough: PassthroughValidator.new,
  }.stringify_keys

  def initialize(request)
    @request = request
  end

  def validate(&on_finish)
    begin
      @request.processing!

      db = DB.find { _1[:id] == @request.db }
      db => {validator:}

      begin
        VALIDATOR.fetch(validator).validate @request
      rescue => e
        @request.objs.base.update! validity: 'error', validation_details: {error: e.message}

        Rails.logger.error e
      else
        @request.objs.base.validity_valid! unless @request.objs.base.validity
      end
    ensure
      @request.finished!
    end

    on_finish&.call
  end
end
