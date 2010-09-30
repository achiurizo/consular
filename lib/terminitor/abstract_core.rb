module Terminitor
  # This AbstractCore defines the basic methods that the Core should inherit
  class AbstractCore
    attr_accessor :terminal, :windows, :working_dir, :termfile

    # set the terminal object, windows, and load the Termfile.
    def initialize(path)
      @termfile = load_termfile(path)
    end

    # Run the setup block in Termfile
    def setup!
      @working_dir = Dir.pwd
      commands = @termfile[:setup].insert(0, "cd #{working_dir}")
      commands.each { |cmd| execute_command(cmd, :in => active_window) }
    end

    # Executes the Termfile
    def process!
      term_windows = @termfile[:windows]
      run_in_window(term_windows['default'], :default => true) unless term_windows['default'].to_s.empty?
      term_windows.delete('default')
      term_windows.each_pair { |window_name, tabs| run_in_window(tabs) }
    end

    # this command will run commands in the designated window
    # run_in_window {:tab1 => ['ls','ok']}
    def run_in_window(tabs, options = {})
      open_window unless options[:default]
      tabs.each_pair do |tab_name,commands|
        tab = open_tab
        commands.insert(0,  "cd \"#{@working_dir}\"") unless @working_dir.to_s.empty?
        commands.each do |cmd|
          execute_command(cmd, :in => tab)
        end
      end
    end

    # Loads commands via the termfile and returns them as a hash
    # if it matches legacy yaml, parse as yaml, else use new dsl
    def load_termfile(path)
      File.extname(path) == '.yml' ? Terminitor::Yaml.new(path).to_hash : Terminitor::Dsl.new(path).to_hash
    end


    ## These methods are core specific methods that need to be defined.
    # yay.

    # Executes the Command
    # execute_command 'cd /path/to', {}
    def execute_command(cmd, options = {})
    end

    # Opens a new tab and returns itself.
    def open_tab
      @working_dir = Dir.pwd # pass in current directory.
    end

    # Returns the current window
    def active_window
    end

    # Opens a new window and returns the tab object.
    def open_window
    end

  end
end
