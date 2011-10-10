# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "consular/version"

Gem::Specification.new do |s|
  s.name        = "consular"
  s.version     = Consular::VERSION
  s.authors     = ["Arthur Chiu"]
  s.email       = ["mr.arthur.chiu@gmail.com"]
  s.homepage    = "http://www.github.com/achiu/consular"
  s.summary     = %q{Quickly setup your terminal windows for your projects}
  s.description = %q{Terminal Automation to get you on your projects quickly}

  s.rubyforge_project = "consular"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'thor'
  s.add_dependency 'activesupport'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'fakefs'

  s.post_install_message = %q{********************************************************************************

    Consular has been installed!  Please run:

      consular init

    This will create a directory at ~/.config/consular which will hold all your global scripts.
    Also a .consularc file will be generated in your HOME directory which you can further configure
    Consular.

********************************************************************************
  }

end
