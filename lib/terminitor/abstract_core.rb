module Terminitor
  # This AbstractCore defines the basic methods that the Core should inherit
  class AbstractCore
    attr_accessor :terminal, :windows, :working_dir, :termfile

    # set the terminal object, windows, and load the Termfile.
    # @param [String] path to termfile
    def initialize(path)
      @termfile = load_termfile(path)
    end

    # Run the setup block in Termfile
    def setup!
      @working_dir = Dir.pwd
      commands = @termfile[:setup].insert(0, "cd #{@working_dir}")
      commands.each { |cmd| execute_command(cmd, :in => active_window) }
    end

    # Executes the Termfile
    def process!
      @working_dir = Dir.pwd
      term_windows = @termfile[:windows]
      run_in_window('default', term_windows['default'], :default => true) unless term_windows['default'][:tabs].empty?
      term_windows.delete('default')
      term_windows.each_pair { |window_name, window_content| run_in_window(window_name, window_content) }
    end

    # this command will run commands in the designated window
    # run_in_window 'window1', {:tab1 => ['ls','ok']}
    # @param [String] name of window
    # @param [Hash] Hash of window's content extracted from Termfile
    # @param [Hash] Hash of options
    def run_in_window(window_name, window_content, options = {})
      window_options = window_content[:options]
      first_tab = true
      window_content[:tabs].keys.sort.each do |tab_key|
        tab_content = window_content[:tabs][tab_key]
        # Open window on first 'tab' statement
        # first tab is already opened in the new window, so first tab should be
        # opened as a new tab in default window only
        tab_options = tab_content[:options]
        tab_name    = tab_options[:name] if tab_options
        if first_tab && !options[:default]
          first_tab = false
          combined_options = (window_options.to_a + tab_options.to_a).inject([]) {|arr, pair| arr += pair }
          window_options = Hash[*combined_options] # safe merge
          tab = window_options.empty? ? open_window(nil) : open_window(window_options)
        else
          tab = ( tab_key == 'default' ? active_window : open_tab(tab_options) ) # give us the current window if its default, else open a tab.
        end
        # append our before block commands.
        tab_content[:commands].insert(0, window_content[:before]).flatten! if window_content[:before]
        # clean up prompt
        tab_content[:commands].insert(0, 'clear') if tab_name || !@working_dir.to_s.empty?
        # add title to tab
        tab_content[:commands].insert(0, "PS1=\"$PS1\\e]2;#{tab_name}\\a\"") if tab_name
        tab_content[:commands].insert(0, "cd \"#{@working_dir}\"") unless @working_dir.to_s.empty?
        tab_content[:commands].each { |cmd| execute_command(cmd, :in => tab) }
      end
      set_delayed_options
    end

    # Loads commands via the termfile and returns them as a hash
    # if it matches legacy yaml, parse as yaml, else use new dsl
    # @param  [String] path to termfile
    # @return [Hash] returns a hash containing termfile details
    def load_termfile(path)
      File.extname(path) == '.yml' ? Terminitor::Yaml.new(path).to_hash : Terminitor::Dsl.new(path).to_hash
    end


    ## These methods are core specific methods that need to be defined.
    # yay.

    # Executes the Command
    # should use the :in key to interact with terminal object.
    # @param [String] command to be ran.
    # @param [Hash] options hash
    # execute_command 'cd /path/to', {:in => #<TerminalObject>}
    def execute_command(cmd, options = {})
    end

    # Opens a new tab and returns itself.
    # @param [Hash] options hash.
    def open_tab(options = nil)
      @working_dir = Dir.pwd # pass in current directory.
    end

    # Returns the current window
    def active_window
    end

    # Opens a new window and returns the tab object.
    # @param [Hahs] options hash.
    def open_window(options = nil)
      @working_dir = Dir.pwd # pass in current directory.      
    end
    
    # For options which should be set after all tabs have been opened
    def set_delayed_options
      @working_dir = Dir.pwd # not nil
    end

  end
end
