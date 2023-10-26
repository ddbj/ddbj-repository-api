class Validators
  VALIDATOR = {
    bioproject: DdbjValidator.new(obj_id: 'BioProject'),
    biosample:  DdbjValidator.new(obj_id: 'BioSample'),
    dra:        DraValidator.new
  }.stringify_keys

  def initialize(request)
    @request = request
  end

  def validate(&on_finish)
    @request.update! status: 'processing'

    db        = DB.find { _1[:id] == @request.db }
    validator = db[:validator]

    VALIDATOR.fetch(validator).validate @request

    on_finish&.call
  ensure
    @request.update! status: 'finished'
  end
end
