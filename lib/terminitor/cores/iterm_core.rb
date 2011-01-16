module Terminitor
  # Mac OS X Core for Terminitor
  # This Core manages all the interaction with Appscript and the Terminal
  class ItermCore < AbstractCore
    include Appscript
    
    ALLOWED_OPTIONS = {
      :window => [:bounds, :visible, :miniaturized],
      :tab => [:settings, :selected]
    }
    
    # Initialize @terminal with Terminal.app, Load the Windows, store the Termfile
    # Terminitor::MacCore.new('/path')
    def initialize(path)
      super
      @terminal = app('iTerm')
      @windows  = @terminal.terminals
      @delayed_options = []
    end
            
    # executes the given command via appscript
    # execute_command 'cd /path/to', :in => #<tab>
    def execute_command(cmd, options = {})      
      if options[:in]
        options[:in].write(:text => "#{cmd}")
      else
        active_window.write(:text => "#{cmd}")
      end
    end

    # Opens a new tab and returns itself.
    # TODO : handle options (?)
    def open_tab(options = nil)
      session = @terminal.current_terminal.sessions.end.make( :new => :session )
      session.exec(:command => ENV['SHELL'])
      session
    end
    
    # Opens A New Window, applies settings to the first tab and returns the tab object.
    # TODO : handle options (?)
    def open_window(options = nil)
      window  = @terminal.make( :new => :terminal )
      session = window.sessions.end.make( :new => :session )
      session.exec(:command => ENV['SHELL'])
      session
    end

    # Returns the Terminal Process
    # We need this method to workaround appscript so that we can instantiate new tabs and windows.
    # otherwise it would have looked something like window.make(:new => :tab) but that doesn't work.
    def terminal_process
      app("System Events").application_processes["iTerm.app"]
    end
    
    # Returns the last instantiated tab from active window
    def return_last_tab
      @terminal.current_terminal.sessions.last.get rescue false
    end

    # returns the active window
    def active_window
      @terminal.current_terminal.current_session.get
    end
    
    # Sets options of the given object
    def set_options(object, options = {})
      options.each_pair do |option, value| 
        case option
        when :settings   # works for windows and tabs, for example :settings => "Grass"
          begin
            object.current_settings.set(@terminal.settings_sets[value])
          rescue Appscript::CommandError => e
            puts "Error: invalid settings set '#{value}'"
          end
        when :bounds # works only for windows, for example :bounds => [10,20,300,200]
          # the only working sequence to restore window size and position! 
          object.bounds.set(value)
          object.frame.set(value)
          object.position.set(value)
        when :selected # works for tabs, for example tab :active => true
          delayed_option(option, value, object)
        when :miniaturized # works for windows only
          delayed_option(option, value, object)
        when :name
          # ignore it.
        else # trying to apply any other option
          begin
            object.instance_eval(option.to_s).set(value)
          rescue
            puts "Error setting #{option} = #{value} on #{object.inspect}"
          end
        end
      end
    end
    
    # Apply delayed options and remove them from the queue
    def set_delayed_options
      @delayed_options.length.times do 
        option = @delayed_options.shift
        option[:object].instance_eval(option[:option]).set(option[:value])
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
    
    # selects options allowed for window or tab
    def allowed_options(object_type, options)
      Hash[ options.select {|option, value| ALLOWED_OPTIONS[object_type].include?(option) }]
    end
    
    # Add option to the list of delayed options
    def delayed_option(option, value, object)
      @delayed_options << {
        :option => option.to_s, 
        :value => value, 
        :object => object
      }
    end
  end
end
