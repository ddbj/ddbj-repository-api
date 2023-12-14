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
    ActiveRecord::Base.transaction do
      @request.processing!

      db        = DB.find { _1[:id] == @request.db }
      validator = VALIDATOR.fetch(db[:validator])

      Rails.error.handle do
        begin
          validator.validate @request
        rescue => e
          @request.objs.base.update! validity: 'error', validation_details: {error: e.message}

          raise
        else
          @request.objs.base.validity_valid! unless @request.objs.base.validity
        end
      end

      raise ActiveRecord::Rollback if @request.reload.canceled?
    ensure
      unless @request.canceled?
        @request.finished!

        on_finish&.call
      end
    end
  end
end
