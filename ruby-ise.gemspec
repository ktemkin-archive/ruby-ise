# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ise/version'

Gem::Specification.new do |gem|
  gem.name          = "ruby-ise"
  gem.version       = ISE::VERSION
  gem.authors       = ["Kyle J. Temkin"]
  gem.email         = ["ktemkin@binghamton.edu"]
  gem.description   = %q{Simple gem which extracts and modifies meta-data from Xilinx ISE files. Intended to simplify using Rake with ruby-adept, and with ISE/XST.}
  gem.summary       = %q{Simple gem which extracts and modifies metadata from Xilinx ISE files.}
  gem.homepage      = "http://www.github.com/ktemkin/ruby-ise"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "inifile"
  gem.add_runtime_dependency "nokogiri"
  gem.add_runtime_dependency "highline"
  gem.add_runtime_dependency "smart_colored"

end
