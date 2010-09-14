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

    def self.source_root; File.dirname(__FILE__); end

    desc "start PROJECT_NAME", "runs the terminitor project"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def start(project="")
      path = resolve_path(project)
      if File.exists?(path)
        do_project(path)
      else
        if project
          say "'#{File.basename(path)}' doesn't exist! Please run 'terminitor open #{project}'"
        else
          say "Termfile doesn't exist! Please run 'terminitor open' in project directory"
        end
      end
    end

    desc "list", "lists all terminitor scripts"
    def list
      Dir.glob("#{ENV['HOME']}/.terminitor/*").each do |file|
        say "#{File.basename(file)} - #{File.read(file).first.gsub("#",'')}"
      end
    end

    desc "setup", "create initial root terminitor folder"
    def setup
      empty_directory "#{ENV['HOME']}/.terminitor"
    end

    desc "open PROJECT_NAME", "open project yaml"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def open(project="")
      path = project.empty? ? File.join(options[:root],"Termfile") : "#{ENV['HOME']}/.terminitor/#{project}.yml"
      template "templates/example.yml.tt", path, :skip => true
      open_in_editor(path)
    end
    
    desc "generate", "create a Termfile in directory"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def create
      invoke :open, [], :root => options[:root]
    end
        
  end
end
