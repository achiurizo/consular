module Terminitor

  class CurrentWindowsConsole
    include Input
    def send_command(cmd)
      # puts "[current] #{cmd}"
      type_in cmd
    end
  end
  

  
  class WindowsConsole
    include Windows::Process
    include Windows::Handle
    include Windows::Window
    include Input
 
    Windows::API.new('SetForegroundWindow', 'L', 'I', 'user32')

    attr_accessor :name
    attr_accessor :parameters
    attr_accessor :title
    attr_reader :pid
    attr_reader :thread_id
    attr_reader :hwnd

    def initialize(options = {})
      @name = options[:name] || name
      @title = options[:title] || name
      @parameters = options[:parameters]

      start
    end

    def start
      command_line = name
      command_line = name + ' ' + parameters if parameters

      # returns a struct, raises an error if fails
      process_info = Process.create(
         :command_line => command_line,
         :close_handles => false,
         :creation_flags => Process::CREATE_NEW_CONSOLE
      )
      @pid = process_info.process_id
      @thread_id = process_info.thread_id
      @process_handle = process_info.process_handle
      @thread_handle = process_info.thread_handle

      @pid
    end

    def kill
      CloseHandle(@process_handle)
      CloseHandle(@thread_handle)

      Process::kill(9, pid)
    end

    def find_window(process_id)
      sleep 0.4 #todo - find a better way to wait for console to show up!!
      child_after = 0
      while (child_after = FindWindowEx(nil, child_after, nil, nil)) > 0 do 
        process_id = 0.chr * 4
        GetWindowThreadProcessId(child_after, process_id)
        process_id = process_id.unpack('L').first
        return child_after if process_id == @pid 
      end
      

      return nil
    end

    def send_command(cmd)
      @hwnd ||= find_window(@thread_id)
      SetForegroundWindow(@hwnd) 
      # puts "[#{@hwnd}] #{cmd}"
      type_in(cmd)
    end
  end

end
