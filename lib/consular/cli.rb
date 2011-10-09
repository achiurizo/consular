require 'thor'

module Consular
  class CLI < Thor
    include Thor::Actions

    TERM_PATH = File.join(ENV['HOME'], '.config', 'consular')

    def self.source_root; File.expand_path('../../', __FILE__); end

    desc 'start PROJECT', 'runs the consular script'
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def start(project = '')
      valid_core.new(termfile_path(project)).process!
    end

    desc 'setup PROJECT', 'run the consular script setup'
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def setup(project = '')
      valid_core.new(termfile_path(project)).setup!
    end

    desc 'list', 'lists all consular scripts'
    def list
      say "Global scripts available: \n"
      Dir.glob("#{TERM_PATH}/*[^~]").each do |file|
        name  = File.basename(file, '.term')
        title = file_comment(file)
        say "  * #{name} - #{title}"
      end
    end

    desc 'init', 'create consular directory'
    def init
      empty_directory TERM_PATH
    end

    desc 'edit PROJECT', 'opens the Termfile to edit'
    method_option :root,    :type => :string,  :default => '.',    :aliases => '-r'
    method_option :editor,  :type => :string,  :default => nil,    :aliases => '-e'
    method_option :capture, :type => :boolean, :default => false,  :aliases => '-c'
    def edit(project = nil)
      type = project && project =~ /\.yml$/ ? 'yml' : 'term'
      path = termfile_path project
      template "templates/example.#{type}.tt", path, :skip => true
      open_in_editor path, options[:editor]
    end

    desc 'delete PROJECT', 'delete the Termfile script'
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def delete(project = nil)
      path = termfile_path(project)
      remove_file path
    end

    no_tasks do

      # Returns the first core that matchees the currrent system.
      #
      # @return [Core] Core that matches the system.
      #
      # @api private
      def valid_core
        Consular.cores.detect { |core| core.valid_system? }
      end
      # Returns the first comment in file. This is used
      # as the title when listing out the scripts.
      #
      # @param [String] file
      #   path to file
      #
      # @api private
      def file_comment(file)
        first_line = File.readlines(file).first
        first_line =~ /^\s*?#/ ? first_line.gsub('#','') : "\n"
      end

      # Returns the full pathname of the Termfile
      #
      # @param [String] project
      #   designated file/project name
      #
      # @return [String] full path name for Termfile.
      #
      # @example
      #   termfile_path           #=> ROOT/Termfile
      #   termfile_path 'foo'     #=> TERM_PATH/foo.term
      #   termfile_path 'bar.yml' #=> TERM_PATH/bar.yml
      #
      # @api semipublic
      def termfile_path(project = nil)
        if !project || project.empty?
           File.join(options[:root], 'Termfile')
        else
          path = project =~ /\..*/ ? project : project + '.term'
          File.join(TERM_PATH, path)
        end
      end

      # Opens Termfile in specified editor.
      #
      # @param [String] path
      #   Path to Termfile
      # @param [String] editor
      #   Editor to open Termfile with.
      #
      # @example
      #   open_in_editor '/path/to/Termfile', 'vim'
      #
      # @api public
      def open_in_editor(path, editor = nil)
        editor = editor || ENV['EDITOR']
        say "please set $EDITOR in your or specify an editor." unless editor
        system "#{editor || 'open'} #{path}"
      end
    end

  end
end
