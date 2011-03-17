module Terminitor
  class CmdCore < AbstractCore
 
    CMD_XLT = {
      'clear' => 'clear', #uncomment when debugging
      'open'  => 'start'
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
      WindowsConsole.new :name=>'cmd'
    end

    def open_window(options = nil)
      WindowsConsole.new :name=>'cmd'
    end 
  end
end



