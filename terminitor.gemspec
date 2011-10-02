# -*- encoding: utf-8 -*-
require File.expand_path("../lib/terminitor/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "terminitor"
  s.version     = Terminitor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Arthur Chiu', 'Nathan Esquenazi']
  s.email       = ['mr.arthur.chiu@gmail.com','nesquena@gmail.com']
  s.homepage    = "http://rubygems.org/gems/terminitor"
  s.summary     = "Automate your development workflow"
  s.description = "Automate your development workflow"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "terminitor"
  
  # Platform Specific Dependencies
  case RUBY_PLATFORM.downcase
  when %r{darwin}
    s.add_dependency "rb-appscript", "~>0.6.1"
  when %r{linux}
    s.add_dependency "ruby-dbus"
  when %r{mswin|mingw}
    s.add_dependency "windows-api", "= 0.4.0"
    s.add_dependency "windows-pr", "= 1.1.2"
    s.add_dependency "win32-process", "= 0.6.4"
  else
  end
  
  s.add_dependency "thor",          "~>0.14.0"
  s.add_dependency "github",        "~>0.6.2"
  s.add_dependency "activesupport", "~>3.1.0"
  s.add_development_dependency "bundler", "~>1.0.0"
  s.add_development_dependency "riot",    "~>0.12.3"
  s.add_development_dependency "rr",      "~>1.0.0"
  s.add_development_dependency "fakefs"
  s.post_install_message = %q{********************************************************************************

    Terminitor is installed!  Please run:
    
      terminitor init

    This will create a directory at ~/.config/terminitor which will hold all your global scripts.

    For those updating from a previous version of Terminitor(<=0.4.1) please run

      terminitor update

    This will copy over your terminitor files from the old path to the newer .config/terminitor location.

********************************************************************************
  }
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end



