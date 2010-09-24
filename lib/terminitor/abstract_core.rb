module Terminitor
  # This AbstractCore defines the basic methods that the Core should inherit
  class AbstractCore
    attr_accessor :terminal, :windows, :working_dir, :termfile

    # set the terminal object, windows, and load the Termfile.
    def initialize(path)
      @termfile = load_termfile(path)
    end

    # Executes the Termfile
    def process!
      term_setups = @termfile[:setup]
      term_windows = @termfile[:windows]
      run_in_window(term_windows['default'], :default => true) unless term_windows['default'].empty?
      term_windows.delete('default')
      term_windows.each_pair { |window_name, tabs| run_in_window(tabs) }
    end

    # this command will run commands in the designated window
    # run_in_window {:tab1 =>}
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
    def load_termfile(path)
      Terminitor::Termfile.new(path).to_hash
    end


    ## This methods are core specific methods that need to be defined.
    # yay.

    # Executes the Command
    # execute_command 'cd /path/to', {}
    def execute_command(cmd, options = {})
    end

    # Opens a new tab and returns itself.
    def open_tab
      @working_dir = Dir.pwd # pass in current directory.
    end

    # Opens a new window and returns the tab object.
    def open_window
    end

  end
end
