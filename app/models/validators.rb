class Validators
  ASSOC = {
    ddbj_validator: DdbjValidator.new
  }.stringify_keys

  def initialize(request)
    @request = request
  end

  def validate(&on_finish)
    @request.update! status: 'processing'

    db   = DB.find { _1[:id] == @request.db }
    objs = db[:objects].select { _1[:validator] }

    Parallel.each objs, in_threads: 4 do |meta|
      id, validator = meta.fetch_values(:id, :validator)

      obj = @request.objs.find { _1.key == id }
      obj.update! validator: validator

      ASSOC.fetch(validator).validate obj, meta
    end

    on_finish&.call
  ensure
    @request.update! status: 'finished'
  end
end
