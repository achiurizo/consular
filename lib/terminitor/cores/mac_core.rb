module Terminitor
  # Mac OS X Core for Terminitor
  # This Core manages all the interaction with Appscript and the Terminal
  class MacCore < AbstractCore
    include Appscript
    
    # Initialize @terminal with Terminal.app, Load the Windows, store the Termfile
    # Terminitor::MacCore.new('/path')
    def initialize(path)
      super
      @terminal = app('Terminal')
      @windows  = @terminal.windows
    end
            
    # executes the given command via appscript
    # execute_command 'cd /path/to', :in => #<tab>
    def execute_command(cmd, options = {})
      active_window.do_script(cmd, options)
    end

    # Opens a new tab and returns itself.
    def open_tab
      super
      terminal_process.keystroke("t", :using => :command_down)
      return_last_tab
    end

    # Opens A New Window and returns the tab object.
    def open_window
      terminal_process.keystroke("n", :using => :command_down)
      return_last_tab
    end

    # Returns the Terminal Process
    # We need this method to workaround appscript so that we can instantiate new tabs and windows.
    # otherwise it would have looked something like window.make(:new => :tab) but that doesn't work.
    def terminal_process
      app("System Events").application_processes["Terminal.app"]
    end
    
    # Returns the last instantiated tab from active window
    def return_last_tab
      local_window = active_window
      local_tabs = local_window.tabs if local_window
      local_tabs.last.get if local_tabs
    end

    # returns the active window by checking if its the :frontmost 
    def active_window
      windows = @terminal.windows.get
      windows.detect do |window|
        window.properties_.get[:frontmost] rescue false
      end
    end

    private
    
    # These methods are here for reference so I can ponder later
    # how I could possibly use them.
    # And Currently aren't tested. =(
    
    # returns a window by the id
    def window_by_id(id)
      @windows.ID(id)
    end

    # grabs the window id.
    def window_id(window)
      window.id_.get
    end

    # set_window_title #<Window>, "hi"
    # Note: This sets all the windows to the same title.
    def set_window_title(window, title)
      window.custom_title.set(title)
    end
    
  end
end
