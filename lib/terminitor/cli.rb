require 'thor'
require File.expand_path('../../terminitor',  __FILE__)

module Terminitor
  class Cli < Thor
    include Thor::Actions
    include Terminitor::Runner

    def self.source_root; File.expand_path('../../',__FILE__); end

    desc "start PROJECT_NAME", "runs the terminitor project"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def start(project="")
      if path = resolve_path(project)
        if RUBY_PLATFORM.downcase.include?("darwin")
          Terminitor::MacCore.new(path).process!
        elsif RUBY_PLATFORM.downcase.include?("linux")
          Terminitor::KonsoleCore.new(path).process!
        else
          say "No suitable terminal for your OS"
        end
      else
        if project
          say "'#{project}' doesn't exist! Please run 'terminitor open #{project.gsub(/\..*/,'')}'"
        else
          say "Termfile doesn't exist! Please run 'terminitor open' in project directory"
        end
      end
    end

    desc "list", "lists all terminitor scripts"
    def list
      say "Global scripts: \n"
      Dir.glob("#{ENV['HOME']}/.terminitor/*").each do |file|
        say "  * #{File.basename(file).gsub('.yml','')} #{grab_comment_for_file(file)}"
      end
    end

    desc "setup", "create initial root terminitor folder"
    def setup
      empty_directory "#{ENV['HOME']}/.terminitor"
    end

    desc "open PROJECT_NAME", "open project yaml"
    method_option :root,    :type => :string, :default => '.', :aliases => '-r'
    method_option :editor,  :type => :string, :default => nil, :aliases => '-c'
    def open(project="")
      path =  config_path(project, :yaml)
      template "templates/example.yml.tt", path, :skip => true
      open_in_editor(path,options[:editor])
    end
    
    desc "generate", "create a Termfile in directory"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def create
      invoke :open, [], :root => options[:root]
    end
    
    desc "delete PROJECT", "delete project script"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def delete(project="")
      path = config_path(project, :yaml)
      remove_file path
    end
        
  end
end
