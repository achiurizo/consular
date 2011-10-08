require 'thor'

module Consular
  class CLI < Thor
    include Thor::Actions

    def self.source_root; File.expand_path('../../', __FILE__); end

    desc 'start PROJECT', 'runs the consular script'
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def start(project = '')
    end

    desc 'setup PROJECT', 'run the consular script setup'
    def setup(project = '')
    end

    desc 'list', 'lists all consular scripts'
    def list
    end

    desc 'init', 'create consular directory'
    def init
    end

    desc 'edit PROJECT', 'opens the Termfile to edit'
    def edit(project = '')
    end

    desc 'create', 'Create a Termfile in the directory'
    def create
    end

    desc 'delete PROJECT', 'delete the Termfile script'
    def delete(project = '')
    end

  end
end
