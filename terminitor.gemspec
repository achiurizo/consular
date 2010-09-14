# -*- encoding: utf-8 -*-
require File.expand_path("../lib/terminitor/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "terminitor"
  s.version     = Terminitor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/terminitor"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "terminitor"

  s.add_dependency "rb-appscript"
  s.add_dependency "yaml"
  s.add_dependency "thor", "~>0.14.0"
  s.add_development_dependency "bundler", "~>1.0.0"
  s.add_development_dependency "riot", "~>0.14.0"
  s.add_development_dependency "rr"
  s.add_development_dependency "fakefs"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
