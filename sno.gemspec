# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sno/version"

Gem::Specification.new do |s|
  s.name        = "sno"
  s.version     = Sno::VERSION
  s.authors     = ["corsen"]
  s.email       = ["bcchaiklin@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{sno - Simple Note Organizer}
  s.description = %q{sno is a simple ruby program to help organize and compile notes into a simple webpage.}

  s.rubyforge_project = "sno"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "RedCloth"
  s.add_runtime_dependency "redcarpet"
end
