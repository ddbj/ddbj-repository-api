task :doc do
  sh 'erb -T - doc/openapi.yaml.erb > public/openapi.yaml'
end
