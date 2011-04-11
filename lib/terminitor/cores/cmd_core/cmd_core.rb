module Terminitor
  class CmdCore < AbstractCore
    attr_reader :current_window

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
      (options[:in] || current_window).send_command(cmd)
    end

    def open_tab(options = {})
      create_window options
    end

    def open_window(options = {})
      create_window options
    end 

    def create_window(options = {})
      c = WindowsConsole.new :name=>'cmd'
      c.send_command "title #{options[:name]}\n" if options[:name]
      c.send_command "mode con: cols=#{options[:bounds][0]} lines=#{options[:bounds][1]}\n" if options[:bounds]
      c
    end
  end
end



