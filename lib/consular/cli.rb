require 'thor'

module Consular

  # The CLI provides the command line interface for Consular. These are
  # interfaced via the consular bin file.
  class CLI < Thor
    include Thor::Actions

    # Source root for Thor to find templates
    def self.source_root; File.expand_path('../../', __FILE__); end

    # Run the Termfile or project script.
    #
    # @param [String] project
    #   Name of the project script. Otherwise leave blank for Termfile.
    #
    # @example
    #
    #   # Executes global script foobar.term
    #   Consular::CLI.start ['start', 'foobar']
    #
    #   # Executes global script foobar.yml
    #   Consular::CLI.start ['start', 'foobar.yml']
    #
    #   # Executes the Termfile
    #   Consular::CLI.start ['start'] # ./Termfile
    #   Consular::CLI.start ['start', '-r=/tmp'] # /tmp/Termfile
    #
    # @api public
    desc 'start [PROJECT]', 'runs the consular script. ex: `consular start` or `consular start foobar`'
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def start(project = nil)
      path = termfile_path(project)
      message_unless_file(path) { valid_core.new(path).process! }
    end

    # Run the Termfile or project script setup.
    #
    # @param [String] project
    #   Name of the project script. Otherwise leave blank for Termfile.
    #
    # @example
    #
    #   # Executes global script setup  for foobar.term
    #   Consular::CLI.start ['setup', 'foobar']
    #
    #   # Executes global script setup for foobar.yml
    #   Consular::CLI.start ['setup', 'foobar.yml']
    #
    #   # Executes the Termfile setup
    #   Consular::CLI.start ['setup'] # ./Termfile
    #   Consular::CLI.start ['setup', '-r=/tmp'] # /tmp/Termfile
    #
    # @api public
    desc 'setup [PROJECT]', 'run the consular script setup. ex: `consular setup` or `consular setup foobar`'
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def setup(project = nil)
      path = termfile_path(project)
      message_unless_file(path) { valid_core.new(path).setup! }
    end

    # Lists all avaiable global scripts
    #
    # @example
    #
    #   Consular::CLI.start ['list']
    #
    # @api public
    desc 'list', 'lists all consular scripts'
    def list
      say "Global scripts available: \n"
      Dir.glob("#{Consular.global_path}/*[^~]").each do |file|
        name  = File.basename(file, '.term')
        title = file_comment(file)
        say "  * #{name} - #{title}"
      end
    end

    # Create the global script directory for Consular.
    #
    # @example
    #
    #   Consular::CLI.start ['init']
    #
    # @api public
    desc 'init', 'create consular directory'
    def init
      empty_directory Consular.global_path
      template 'templates/consularc.tt', File.join(ENV['HOME'],'.consularc'), :skip => true
    end

    # Edit the specified global script or Termfile.
    #
    # @param [String] project
    #   Name of project script.
    #
    # @example
    #
    #   # opens foobar for editing
    #   Consular::CLI.start ['edit', 'foobar']
    #   # opens foobar with specified editor
    #   Consular::CLI.start ['edit', 'foobar', '-e=vim']
    #   # opens /tmp/Termfile
    #   Consular::CLI.start ['edit', '-r=/tmp']
    #
    # @api public
    desc 'edit [PROJECT]', 'opens the Termfile to edit. ex: `consular edit` or `consular edit foobar`'
    method_option :root,    :type => :string,  :default => '.',    :aliases => '-r'
    method_option :editor,  :type => :string,  :default => nil,    :aliases => '-e'
    method_option :capture, :type => :boolean, :default => false,  :aliases => '-c'
    def edit(project = nil)
      type = project && project =~ /\.yml$/ ? 'yml' : 'term'
      path = termfile_path project
      template "templates/example.#{type}.tt", path, :skip => true
      open_in_editor path, options[:editor]
    end

    # Create a Termfile in the current or specified directory
    #
    # @example
    #
    #   # create Termfile in current directory
    #   Consular::CLI.start ['create']
    #   # create Termfile in /tmp 
    #   Consular::CLI.start ['create', '-r=/tmp']
    #
    # @api public
    desc "create", "create a Termfile in directory"
    method_option :root,    :type => :string, :default => '.', :aliases => '-r'
    method_option :editor,  :type => :string,  :default => nil,    :aliases => '-e'
    method_option :capture, :type => :boolean, :default => false,  :aliases => '-c'
    def create
      invoke :edit, [], options
    end

    # Delete the global script or Termfile
    #
    # @param [String] project
    #   Name of the project script.
    #
    # @example
    #
    #   # deletes global script foobar.term
    #   Consular::CLI.start ['delete', 'foobar']
    #   # deletes global script foobar.yml
    #   Consular::CLI.start ['delete', 'foobaryml']
    #   # deletes /tmp/Termfile
    #   Consular::CLI.start ['delete', '-r=/tmp']
    #
    # @api public
    desc 'delete [PROJECT]', 'delete the Termfile script. ex: `consular delete` or `consular delete foobar`'
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def delete(project = nil)
      path = termfile_path(project)
      message_unless_file(path) { remove_file path }
    end

    no_tasks do

      # Returns the first core that matchees the currrent system.
      #
      # @return [Core] Core that matches the system.
      #
      # @api private
      def valid_core
        cores = Consular.cores.select { |core| core.valid_system? }
        if cores.nil? || cores.empty?
          say "No valid core was found!. Exiting...", :red
          raise SystemExit
        elsif cores.size > 1
          core_selection cores
        else
          cores.first
        end
      end

      # Returns a dialoag to select the desired core.
      #
      # @param [Array<Core>] Array of cores
      #
      # @return [Core] core from selection
      #
      # @api private
      def core_selection(cores)
        say "Multiple cores match the current system:", :yellow
        cores.each_with_index do |core, index|
          say "  [#{index}] - #{core.to_s}"
        end
        num = ask "Please select the number choice of the core to use: "
        cores[num.to_i]
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
      #   termfile_path 'foo'     #=> GLOBAL_PATH/foo.term
      #   termfile_path 'bar.yml' #=> GLOBAL_PATH/bar.yml
      #
      # @api private
      def termfile_path(project = nil)
        if !project || project.empty?
           File.join(options[:root], 'Termfile')
        else
          path = project =~ /\..*/ ? project : project + '.term'
          Consular.global_path path
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
      # @api private
      def open_in_editor(path, editor = nil)
        editor = editor || Consular.default_editor || ENV['EDITOR']
        system "#{editor || 'open'} #{path}"
      end

      # Returns an error message unless the file exists. If it does
      # execute the block
      #
      # @param [String] file
      #   Path of file
      # @param [Proc] blk
      #   Proc to execute if file exists.
      #
      # @api private
      def message_unless_file(file, &blk)
        if File.exists?(File.expand_path(file))
          blk.call
        else
          say "#{file} does not exist. Try running `consular edit` first.", :yellow
        end
      end
    end

  end
end
