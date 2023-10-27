class Doc < Thor
  include Thor::Actions

  def self.exit_on_failure? = true
  def self.source_root = File.expand_path('../../doc', __dir__)

  desc 'openapi', 'Generate openapi.yaml'
  def openapi
    template 'openapi.yaml.erb', 'public/openapi.yaml'
  end
end
