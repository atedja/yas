$:.push File.expand_path("../lib", __FILE__)
require 'yas/version'

Gem::Specification.new do |s|
  s.name = "#{YAS::GEM_NAME}"
  s.version = YAS::VERSION
  s.authors = ["Albert Tedja"]
  s.email = "nicho_tedja@yahoo.com"
  s.homepage = "https://github.com/atedja/yahs"
  s.summary = "Yet Another Schema for Ruby."
  s.description = "#{YAS::NAME} is a Ruby hash schema and validator."

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = '~> 2.0'
  s.add_development_dependency 'minitest',  '~> 5.3'
  s.add_development_dependency 'mocha', '~> 1.1'
  s.add_development_dependency 'rake', '~> 10.3'

  s.license = "Apache"
end
