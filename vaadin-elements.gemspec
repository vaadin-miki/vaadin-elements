# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vaadin/elements/version'

Gem::Specification.new do |spec|
  spec.name = "vaadin-elements"
  spec.version = Vaadin::VERSION
  spec.authors = ["Miki"]
  spec.email = ["miki@vaadin.com"]

  spec.summary = %q{Low-level library to be used in web-applications to use Vaadin Elements in HTML.}
  spec.description = %q{This gem consists mostly of helpers related to generating JS, as well as some methods used in communication.}
  spec.homepage = "http://www.github.com/vaadin-miki/vaadin-elements"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
