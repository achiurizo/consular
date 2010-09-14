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
      file = "#{project.sub(/\.yml$/, '')}.yml"
      path = File.join(ENV['HOME'],'.terminitor', file)
      if File.exists?(path)
        do_project(path)
      else
        say "#{file} doesn't exist! Please run terminitor open #{project}"
      end
    end

    desc "setup", "create initial root terminitor folder"
    def setup
      empty_directory "#{ENV['HOME']}/.terminitor"
    end

    desc "open PROJECT_NAME", "open project yaml"
    def open(project)
      path = "#{ENV['HOME']}/.terminitor/#{project}.yml"
      create_file path, :skip => true
      open_in_editor(path)
    end
  end
end
