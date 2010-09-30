# -*- encoding: utf-8 -*-
require File.expand_path("../lib/terminitor/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "terminitor"
  s.version     = Terminitor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Arthur Chiu', 'Nathan Esquenazi']
  s.email       = ['mr.arthur.chiu@gmail.com','nesquena@gmail.com']
  s.homepage    = "http://rubygems.org/gems/terminitor"
  s.summary     = "Outsource your workflow to Skynet"
  s.description = "Automate your development workflow"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "terminitor"
  
  # Platform Specific Dependencies
  case RUBY_PLATFORM.downcase
  when %r{darwin}
    s.add_dependency "rb-appscript"
  else
  end
  
  s.add_dependency "thor", "~>0.14.0"
  s.add_dependency "github"
  s.add_development_dependency "bundler", "~>1.0.0"
  s.add_development_dependency "riot", "~>0.11.0"
  s.add_development_dependency "rr"
  s.add_development_dependency "fakefs"
  s.post_install_message = %q{********************************************************************************

    Terminitor is installed! 
    Please run 'terminitor init'. 
    This will create a directory at ~/.terminitor which will hold all your global scripts.
    Thanks!

********************************************************************************
  }
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
