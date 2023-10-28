class Doc < Thor
  include Thor::Actions

  def self.exit_on_failure? = true
  def self.source_root = File.expand_path('../..', __dir__)

  desc 'openapi', 'Generate openapi.yaml'
  def openapi
    template 'doc/openapi.yaml.erb', 'doc/openapi.yaml'
  end
end
