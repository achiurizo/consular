module Terminitor
  class CmdCore < AbstractCore
 
    CMD_XLT = {
      'clear' => 'cls'
    }
    
    def initialize(path)
      @current_window = CurrentWindowsConsole.new
      super
    end

    def execute_command(cmd, options = {})
      cmd = CMD_XLT[cmd] || cmd
      cmd += "\n" if (cmd =~ /\n\Z/).nil?
      (options[:in] || @current_window).send_command(cmd)
    end

    def open_tab(options = nil)
      create_window 
    end

    def open_window(options = nil)
      create_window
    end 

    def create_window
      WindowsConsole.new :name=>'cmd'
    end
  end
end



