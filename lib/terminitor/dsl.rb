module Terminitor
  # This class parses the Termfile to fit the new Ruby Dsl Syntax
  class Dsl

    # @param [String] path to termfile
    def initialize(path)
      file = File.read(path)
      @setup    = []
      @windows  = { 'default' => {:tabs => {'default' =>{:commands=>[]}}}}
      @_context = @windows['default']
      instance_eval(file)
    end

    # Contains all commands that will be run prior to the usual 'workflow'
    # e.g bundle install, setup forks, etc ...
    # @param [Array<String>] array of commands
    # @param [Proc]
    # @example
    #   setup "bundle install", "brew update"
    #   setup { run('bundle install') }
    def setup(*commands, &block)
      if block_given?
        in_context @setup, &block
      else
        @setup.concat(commands)
      end
    end

    # sets command context to be run inside a specific window
    # @param [Hash] options hash.
    # @param [Proc] 
    # @example
    #   window(:name => 'new window', :size => [80,30], :position => [9, 100]) { tab('ls','gitx') }
    #   window { tab('ls', 'gitx') }
    def window(options = {}, &block)
      window_name     = "window#{@windows.keys.size}"
      window_contents = @windows[window_name] = {:tabs => {'default' => {:commands =>[]}}}
      window_contents[:options] = options unless options.empty?
      in_context window_contents, &block
    end

    # stores command in context
    # @param [Array<String>] Array of commands
    # @example
    #   run 'brew update'
    def run(*commands)
      # if we are in a window context, append commands to default tab.
      if @_context.is_a?(Hash) && @_context[:tabs]
        current = @_context[:tabs]['default'][:commands]
      elsif @_context.is_a?(Hash)
        current = @_context[:commands]
      else
        current = @_context
      end
      current << commands.map do |c|
        c =~ /&$/ ? "(#{c})" : c
      end.join(" && ")
    end

    # runs commands before each tab in window context
    # @param [Array<String>] Array of commands
    # @param [Proc]
    # @example
    #   window do
    #     before { run 'whoami' }
    #   end
    def before(*commands, &block)
      @_context[:before] ||= []
      if block_given?
        in_context @_context[:before], &block
      else
        @_context[:before].concat(commands)
      end
    end

    # sets command context to be run inside specific tab
    # @param [Array<String>] Array of commands
    # @param [Proc]
    # @example
    #   tab(:name => 'new tab', :settings => 'Grass') { run 'mate .' }
    #   tab 'ls', 'gitx'
    def tab(*args, &block)
      tabs     = @_context[:tabs]
      tab_name = "tab#{tabs.keys.size}"
      if block_given?
        tab_contents = tabs[tab_name] = {:commands => []}
        
        options = {}
        options = args.pop          if args.last.is_a? Hash
        options[:name] = args.first if args.first.is_a?(String) || args.first.is_a?(Symbol)
        
        tab_contents[:options] = options unless options.empty?
        
        in_context tab_contents, &block
        clean_up_context
      else
        tabs[tab_name] = { :commands => args}
      end
    end

    def pane(*args, &block)
      @_context[:panes] = {} unless @_context.has_key? :panes 
      panes = @_context[:panes]
      pane_name = "pane#{panes.keys.size}"
      if block_given?
        pane_contents = panes[pane_name] = {:commands => []}
        if @_context.has_key? :is_first_lvl_pane
          # after in_context  we should be able to access
          # @_context and @_old_context as before
          context = @_context
          old_context = @_old_context
          in_context pane_contents[:commands], &block
          clean_up_context(context, old_context)
        else
          pane_contents[:is_first_lvl_pane] = true
          in_context pane_contents, &block
        end
      else
        panes[pane_name] = { :commands => args }
      end
    end

    # Returns yaml file as Terminitor formmatted hash
    # @return [Hash] Return hash format of Termfile
    def to_hash
      { :setup => @setup, :windows => @windows }
    end

    private

    # in_context @setup, &block
    # in_context @tabs["name"], &block
    def in_context(context, &block)
      @_context, @_old_context = context, @_context
      instance_eval(&block)
      @_context = @_old_context
    end
    
    def clean_up_context(context = last_open_window, old_context = nil)
      @_context = context
      @_old_context = old_context
    end

    def last_open_window
      @windows[@windows.keys.last]
    end
  end
end
