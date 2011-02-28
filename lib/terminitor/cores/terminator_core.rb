module Terminitor

  # Terminator core for Terminitor.
  #
  # Since Terminator doesn't have a complete IPC interface,
  # everything is done by using "xdotool" to simulate keypresses.
  class TerminatorCore < AbstractCore
    def initialize(path)
      abort("xdotool required for Terminator support") if (@xdotool = `which xdotool`.chomp).empty?
      super
    end

    def execute_command(cmd, options = {})
      # add a cr to the end if missing
      cmd += "\n" if (cmd =~ /\n\Z/).nil?
      run_in_active_terminator cmd, options
      true
    end

    def open_tab(options = nil)
      send_keypress "ctrl+shift+t", options
    end

    def open_window(options = nil)
      send_keypress "ctrl+shift+i", options
    end

    protected

    # Run arbitrary command in active terminator window.
    # abort()s if the active window is not a terminator window.
    #
    # @param cmd [String] command.
    # @param options [Hash] options hash.
    def run_in_active_terminator(cmd, options)
      winid = window_id
      type_in_window winid, cmd
    end

    # Send keypresses to active window.
    #
    # @param keys [String] keypresses in the form expected by xdotool.
    # @param options [Hash] options hash from terminitor.
    def send_keypress(keys, options)
      winid = window_id
      xdotool("key --window #{winid} #{keys}")
    end

    # Get the X11 window ID of the active terminator window.
    #
    # If the active window is not a terminator window, abort.
    #
    # @return [String] X11 window ID of active terminator window.
    def window_id
      active = get_active_window
      if get_terminator_windows.include? active
        return active
      else
        abort("not running in Terminator")
      end
    end

    # Use xdotool to get the window id of the active window.
    #
    # @return [String] active X11 window ID.
    def get_active_window
      xdotool("getactivewindow").chomp
    end

    # Use xdotool to get the window IDs of all visible
    # terminator windows.
    #
    # @return [Array] String array of terminator window IDs.
    def get_terminator_windows
      xdotool("search --onlyvisible --class terminator").split("\n")
    end

    # Focus window with given id.
    #
    # @param id [String] X11 window id.
    def focus_window(id)
      xdotool("windowfocus #{id}")
    end

    # Raise window with given id.
    #
    # @param id [String] X11 window id.
    def raise_window(id)
      xdotool("windowraise #{id}")
    end

    # Send arbitrary text to given window.
    #
    # @param winid [String] X11 window id.
    # @param text [String] text to type.
    def type_in_window(winid, text)
      xdotool("type --window #{winid} \"#{text}\"")
    end

    # Run arbitrary xdotool commands.
    #
    # @param cmd [String] command as string.
    # @return [String] result as string.
    def xdotool(cmd)
      execute("#{@xdotool} #{cmd}")
    end

    # Execute arbitrary command and return result string.
    #
    # @param cmd [String] command string.
    # @return [String] result as string.
    def execute(cmd)
      IO.popen(cmd).read
    end
  end
end

