class Validators
  ASSOC = {
    ddbj_validator: DdbjValidator
  }.stringify_keys

  def initialize(request)
    @request = request
  end

  def validate(&on_finish)
    @request.update! status: 'processing'

    db   = DB.find { _1[:id] == @request.db }
    objs = db[:objects].select { _1[:validator] }

    Parallel.each objs, in_threads: 4 do |meta|
      obj = @request.objs.find { _1.key == meta[:id] }

      ASSOC.fetch(meta[:validator]).new(obj, meta).validate
    end

    on_finish&.call
  ensure
    @request.update! status: 'finished'
  end
end
