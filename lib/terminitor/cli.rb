require 'thor'

module Terminitor
  class Cli < Thor
    include Thor::Actions
    include Terminitor::Runner

    def self.source_root; File.expand_path('../../',__FILE__); end

    desc "start PROJECT_NAME", "runs the terminitor script"
    method_option :root,    :type => :string, :default => '.',    :aliases => '-r'
    def start(project="")
      execute_core :process!, project
    end

    desc "setup PROJECT_NAME", "execute setup in the terminitor script"
    method_option :root,    :type => :string, :default => '.',    :aliases => '-r'
    def setup(project="")
      execute_core :setup!, project
    end

    desc "fetch USERNAME PROJECT_NAME", "clone the designated repo and run setup"
    method_option :root,    :type => :string, :default => '.',    :aliases => '-r'
    method_option :setup, :type => :boolean, :default => true
    def fetch(username, project)
      fetch_repo username, project, options
    end

    desc "list", "lists all terminitor scripts"
    def list
      say "Global scripts: \n"
      Dir.glob("#{ENV['HOME']}/.terminitor/*").each do |file|
        say "  * #{File.basename(file).gsub('.yml','')} #{grab_comment_for_file(file)}"
      end
    end

    desc "init", "create initial root terminitor folder"
    def init
      empty_directory "#{ENV['HOME']}/.terminitor"
    end

    desc "edit PROJECT_NAME", "open termitor script"
    method_option :root,    :type => :string, :default => '.',    :aliases => '-r'
    method_option :editor,  :type => :string, :default => nil,    :aliases => '-c'
    method_option :syntax,  :type => :string, :default => 'term', :aliases => '-s'
    def edit(project="")
      syntax = project.empty? ? 'term' : options[:syntax] # force Termfile to use term syntax
      path =  config_path(project, syntax.to_sym)
      template "templates/example.#{syntax}.tt", path, :skip => true
      open_in_editor(path,options[:editor])
    end

    desc "open PROJECT_NAME", "this is deprecated. please use 'edit' instead"
    method_option :root,    :type => :string, :default => '.', :aliases => '-r'
    method_option :syntax,  :type => :string, :default => 'term', :aliases => '-s'
    def open(project="")
      say "'open' is now deprecated. Please use 'edit' instead"
      invoke :edit, [project], options
    end


    desc "create", "create a Termfile in directory"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def create
      invoke :edit, [], options
    end

    desc "delete PROJECT_NAME", "delete terminitor script"
    method_option :root,    :type => :string, :default => '.',    :aliases => '-r'
    method_option :syntax,  :type => :string, :default => 'term', :aliases => '-s'
    def delete(project="")
      path = config_path(project, options[:syntax].to_sym)
      remove_file path
    end

  end
end
