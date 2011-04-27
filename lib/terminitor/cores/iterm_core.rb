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
      session = current_terminal.sessions.end.make( :new => :session )
      session.exec(:command => ENV['SHELL'])
      session
    end
    
    # Opens A New Window, applies settings to the first tab and returns the tab object.
    # TODO : handle options (?)
    def open_window(options = nil)
      window  = terminal.make( :new => :terminal )
      session = window.sessions.end.make( :new => :session )
      session.exec(:command => ENV['SHELL'])
      session
    end

    # Returns the Terminal Process
    # We need this method to workaround appscript so that we can instantiate new tabs and windows.
    # otherwise it would have looked something like window.make(:new => :tab) but that doesn't work.
    def terminal_process
      Appscript.app("System Events").processes["iTerm"]
    end
    
    # Returns the last instantiated tab from active window
    def return_last_tab
      current_terminal.sessions.last.get rescue false
    end

    # returns the active windows
    def active_window
      current_terminal.current_session.get
    end
    
    # Returns the current terminal
    def current_terminal
      @terminal.current_terminal
    end

    def last_session
      current_terminal.sessions.last
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

    # this command will run commands in the designated window
    # run_in_window 'window1', {:tab1 => ['ls','ok']}
    # @param [String] name of window
    # @param [Hash] Hash of window's content extracted from Termfile
    # @param [Hash] Hash of options
    #
    # this method is hideous and needs a refactoring!
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
        tab_content[:commands].insert(0, "PS1=$PS1\"\\e]2;#{tab_name}\\a\"") if tab_name
        tab_content[:commands].insert(0, "cd \"#{@working_dir}\"") unless @working_dir.to_s.empty?
        # if tab_content hash has a key :panes we know this tab should be split
        # we can execute tab commands as before if there is no key :panes
        if tab_content.key?(:panes)
          handle_panes(tab_content) 
        else
          tab_content[:commands].each { |cmd| execute_command(cmd, :in => tab) }
        end
      end
      set_delayed_options
    end
    
    # handle panes
    # 
    def handle_panes(tab_content)
      panes = tab_content[:panes]
      tab_commands = tab_content[:commands]
      first_pane = true
      panes.keys.sort.each do |pane_key|
        # split and execute commands
        split_v unless first_pane
        first_pane = false if first_pane
        pane_commands = panes[pane_key][:commands] 
        # tab commands in each pane
        pane_commands = tab_commands + pane_commands        
        pane_commands.each {|cmd| execute_command cmd, :in => last_session}
        #check if pane includes a pane
        # puts "awesome there's a subpane I have to split_h here" if panes[pane_key].keys.include?(:panes)
      end
    end


    # Methods for splitting panes
    #
    # Note:
    # Panes can be addressed via terminal.sessions-array.
    # Panes are listed in the sessions-array from left to right
    # and numbered from 1 - n.
    #
    # terminal.sessions[1].terminate
    # 
    #    ########################################
    #    #            #            #            #
    #    # session[1] #            #            #
    #    #            # session[4] #            #
    #    ##############            #            #
    #    #            #            #            #
    #    # session[2] ############## session[6] #
    #    #            #            #            #
    #    ##############            #            #
    #    #            # session[5] #            #
    #    # session[3] #            #            #
    #    #            #            #            #
    #    ########################################
    #
    # Numbering sessions from left to right applies to tabs as well.
    # If there was a second tab the first session of the second tab
    # would be session [7] and so on.
    def iterm_menu
      terminal_process.menu_bars.first
    end
    
    def call_ui_action(menu, submenu = nil, action)
      menu = iterm_menu.menu_bar_items[menu].menus[menu]
      if submenu
        menu = menu.menu_items[submenu].menus[submenu]
      end
      menu.menu_items[action].click
    end

    def split_v
      call_ui_action("Shell", nil, "Split vertically")
    end

    def split_h
      call_ui_action("Shell", nil, "Split horizontally")
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
