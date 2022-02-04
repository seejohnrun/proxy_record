lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'proxy_record'
  s.summary = 'A proxy for AR objects'
  s.authors = ['seejohnrun']
  s.version = '0.0.1'
end
