require 'rubygems'
require 'thor'
require 'appscript'
require 'yaml'
require File.expand_path('../terminitor/runner',__FILE__)

module Terminitor
  class Cli < Thor
    include Thor::Actions
    include Terminitor::Runner
    include Appscript

    desc "start PROJECT_NAME", "runs the terminitor project"
    def start(project)
      do_project(project)
    end

    desc "setup", "create initial root terminitor folder"
    def setup
      empty_directory "#{ENV['HOME']}/.terminitor"
    end

    desc "open PROJECT_NAME", "open project yaml"
    def open(project)
      path = "#{ENV['HOME']}/.terminitor/#{project}.yml"
      create_file path
      open_in_editor(path)
    end

  end
end
