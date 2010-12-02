module Terminitor
  # This class parses the Termfile to fit the new Ruby Dsl Syntax
  class Dsl

    def initialize(path)
      file = File.read(path)
      @setup    = []
      @windows  = { 'default' => {:tabs => {'default' =>{:commands=>[]}}}}
      @_context = @windows['default']
      instance_eval(file)
    end

    # Contains all commands that will be run prior to the usual 'workflow'
    # e.g bundle install, setup forks, etc ...
    # setup "bundle install", "brew update"
    # setup { run('bundle install') }
    def setup(*commands, &block)
      if block_given?
        in_context @setup, &block
      else
        @setup.concat(commands)
      end
    end

    # sets command context to be run inside a specific window
    # window(:name => 'new window', :size => [80,30], :position => [9, 100]) { tab('ls','gitx') }
    # window { tab('ls', 'gitx') }
    def window(options = {}, &block)
      window_name     = "window#{@windows.keys.size}"
      window_contents = @windows[window_name] = {:tabs => {'default' => {:commands =>[]}}}
      window_contents[:options] = options unless options.empty?
      in_context window_contents, &block
    end

    # stores command in context
    # run 'brew update'
    def run(command)
      if @_context.is_a?(Hash) && @_context[:tabs] # if we are in a window context, append commands to default tab.
        @_context[:tabs]['default'][:commands]<<(command)
      else
        @_context<<(command)
      end
    end

    # runs commands before each tab in window context
    # window do
    #   before { run 'whoami' }
    # end
    def before(*commands, &block)
      @_context[:before] ||= []
      if block_given?
        in_context @_context[:before], &block
      else
        @_context[:before].concat(commands)
      end
    end

    # sets command context to be run inside specific tab
    # tab(:name => 'new tab', :settings => 'Grass') { run 'mate .' }
    # tab 'ls', 'gitx'
    def tab(options = {}, *commands, &block)
      tabs     = @_context[:tabs]
      tab_name = "tab#{tabs.keys.size}"
      if block_given?
        tab_contents = tabs[tab_name] = {:commands => []}
        tab_contents[:options] = options unless options.empty?
        in_context tab_contents[:commands], &block
      else
        tabs[tab_name] = { :commands => [options] + commands}
      end
    end

    # Returns yaml file as Terminitor formmatted hash
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


  end
end
