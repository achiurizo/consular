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

    # Opens a new tab, iterm sets focus on new tab 
    # TODO : handle options (?)
    def open_tab(options = nil)
      current_terminal.launch_ :session => 'New session'
    end

    # Open new window, applies settings to the first tab. iterm sets focus on 
    # new tab
    # TODO : handle options (?)
    def open_window(options = nil)
      window  = terminal.make( :new => :terminal )
      window.launch_ :session => 'New session'
    end

    # Returns the active window i.e. the active terminal session in iTerm 
    def active_window
      current_terminal.current_session
    end

    # Returns the current terminal i.e. the active iTerm window
    def current_terminal
      @terminal.current_terminal
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
        # give us the current window if its default, else open a tab.
          tab = ( tab_key == 'default' ? active_window : open_tab(tab_options) )
        end
        # append our before block commands.
        tab_content[:commands].insert(0, window_content[:before]).flatten! if window_content[:before]
        # clean up prompt
        tab_content[:commands].insert(0, 'clear') if tab_name || !@working_dir.to_s.empty?
        # add title to tab
        tab_content[:commands].insert(0, "PS1=\"$PS1\\[\\e]2;#{tab_name}\\a\\]\"") if tab_name
        tab_content[:commands].insert(0, "cd \"#{@working_dir}\"") unless @working_dir.to_s.empty?
        # if tab_content hash has a key :panes we know this tab should be split
        # we can execute tab commands if there is no key :panes
        if tab_content.key?(:panes)
          handle_panes(tab_content) 
        else
          tab_content[:commands].each { |cmd| execute_command(cmd, :in => tab) }
        end
      end
      set_delayed_options
    end

    def handle_panes(tab_content)
      panes = tab_content[:panes]
      tab_commands = tab_content[:commands]
      first_pane_level_split(panes, tab_commands)
      second_pane_level_split(panes, tab_commands)
    end

    def first_pane_level_split(panes, tab_commands)
      first_pane = true
      split_v_counter = 0
      panes.keys.sort.each do |pane_key|
        pane_content = panes[pane_key]
        unless first_pane
          split_v
          split_v_counter += 1 
        end
        first_pane = false if first_pane
        pane_commands = pane_content[:commands] 
        execute_pane_commands(pane_commands, tab_commands)
      end
      split_v_counter.times { select_pane 'Left' }
    end

    def second_pane_level_split(panes, tab_commands)
      panes.keys.sort.each do |pane_key|
        pane_content = panes[pane_key]
        handle_subpanes(pane_content[:panes], tab_commands) if pane_content.has_key? :panes
        # select next vertical pane
        select_pane 'Right'
      end
    end

    def handle_subpanes(subpanes, tab_commands)
      subpanes.keys.sort.each do |subpane_key|
        subpane_commands = subpanes[subpane_key][:commands]
        split_h
        execute_pane_commands(subpane_commands, tab_commands)
      end
    end

    def execute_pane_commands(pane_commands, tab_commands)
      pane_commands = tab_commands + pane_commands
      pane_commands.each { |cmd| execute_command cmd}
    end


    # Methods for splitting panes (GUI_scripting)
    #
    def iterm_menu
      terminal_process = Appscript.app("System Events").processes["iTerm"]
      terminal_process.menu_bars.first
    end

    def call_ui_action(menu, submenu, action)
      menu = iterm_menu.menu_bar_items[menu].menus[menu]
      menu = menu.menu_items[submenu].menus[submenu] if submenu
      menu.menu_items[action].click
    end

    def split_v
      call_ui_action("Shell", nil, "Split Vertically With Same Profile")
    end

    def split_h
      call_ui_action("Shell", nil, "Split Horizontally With Same Profile")
    end

    # to select panes; iTerm's Appscript select method does not work
    # as expected, we have to select via menu instead
    def select_pane(direction)
      valid_directions = %w[Above Below Left Right]
      if valid_directions.include?(direction)
        call_ui_action("Window", "Select Split Pane", "Select Pane #{direction}")
      else
        puts "Error: #{direction} is not a valid direction to select a pane; Only Above/Below/Left/Right are valid directions"
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
