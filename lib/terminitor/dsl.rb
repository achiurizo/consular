require 'active_support/ordered_hash'
module Terminitor

  # The Dsl class provides the DSL for the Terminitor scripting file.
  # It provides the basic commands such as:
  #   #setup  - commands to run when invoked by 'terminitor setup'
  #   #window - commands to run in the context of a window
  #   #tab    - commands to run in the context of tab
  #   #before - commands to run in the context before every tab context
  #
  # The Dsl class can be extended to provide additional API's for core specific
  # DSL.
  class Dsl

    attr_reader :_setup, :_windows, :_context

    # Initializes the Dsl library and stores the commands.
    #
    # @param [String] path
    #   path to Terminitor script/ Termfile
    #
    # @example
    #   Terminitor::Dsl.new 'foo/bar.term'
    #
    # @api public
    def initialize(path)
      @_setup              = []
      @_windows            = ActiveSupport::OrderedHash.new
      @_windows['default'] = window_hash
      @_context            = @_windows['default']
      instance_eval File.read(path), __FILE__, __LINE__
    end

    # Run commands using prior to the workflow using the command `terminitor setup`.
    # This allows you to perform any command that needs to be ran prior to setup
    # a particular project/script.
    #
    # @param [Array<String>] commands
    #   Commands to be executed.
    # @param [Proc] block
    #   Proc of commands to run.
    #
    # @example
    #   setup 'bundle install', 'brew update'
    #   setup { run 'bundle install' }
    #
    # @api public
    def setup(*commands, &block)
      block_given? ? run_context(@_setup, &block) : @_setup.concat(commands)
    end

    # Run commands prior to each tab context.
    #
    # @param [Array<String>] commands
    #   Commands to be executed.
    # @param [Proc] block
    #   Proc of commands to run
    #
    # @example
    #   # Executes `whoami` before tab with `ls` and `gitx`
    #   window do
    #     before { run 'whoami' }
    #     tab 'ls'
    #     tab 'gitx'
    #   end
    #
    # @api public
    def before(*commands, &block)
      context = (@_context[:before] ||= [])
      block_given? ? run_context(context, &block) : context.concat(commands)
    end

    # Run commands in the conext of a window.
    #
    # @param [Hash] options
    #   Hash to pass options to each context of a window. Each core can
    #   implement the desired behavior for the window based on the options set here.
    # @param [Proc] block
    #   block of commands to run in window context.
    #
    # @example
    #   window :name => 'my project', :size => [80, 30] do
    #     run 'ps aux'
    #   end
    #
    # @api public
    def window(options = {}, &block)
      key     = "window#{@_windows.keys.size}"
      context = (@_windows[key] = window_hash.merge(:options => options))
      run_context context, &block
    end

    # Run commands in the context of a tab.
    #
    # @param [Array] args
    #   Accepts either:
    #     - an array of string commands
    #     - a hash containing options for the tab.
    # @param [Proc] block
    #
    # @example
    #   tab :name => 'first tab' do
    #     run 'ps aux'
    #   end
    #
    #   tab 'ls', 'gitx'
    #
    # @api public
    def tab(*args, &block)
      tabs = @_context[:tabs]
      key  = "tab#{tabs.keys.size}"
      return (tabs[key] = { :commands => args }) unless block_given?

      context           = (tabs[key] = {:commands => []})
      context[:options] = args.first.is_a?(Hash) ? args.pop : {}

      run_context context, &block
      @_context = @_windows[@_windows.keys.last] # Jump back out into the context of the last window.
    end

    # Store commands to run in context.
    #
    # @param [Array<String>] commands
    #   Array of commands to be executed.
    #
    # @example
    #   run 'brew update', 'gitx'
    #
    # @api public
    def run(*commands)
      context = case
                when @_context.is_a?(Hash) && @_context[:tabs]
                  @_context[:tabs]['default'][:commands]
                when @_context.is_a?(Hash)
                  @_context[:commands]
                else
                  @_context
                end
      context << commands.map { |c| c =~ /&$/ ? "(#{c})" : c }.join(" && ")
    end


    # Generates a pane in the terminal. These can be nested to
    # create horizontal panes. Vertical panes are created with each top
    # level nest.
    # @param [Array<String>] Array of comamnds
    # @param [Proc]
    # @example
    #   pane "top"
    #   pane { pane "uptime" }
    def pane(*args, &block)
      @_context[:panes] = {} unless @_context.has_key? :panes 
      panes = @_context[:panes]
      pane_name = "pane#{panes.keys.size}"
      if block_given?
        pane_contents = panes[pane_name] = {:commands => []}
        if @_context.has_key? :is_first_lvl_pane
          # after run_context  we should be able to access
          # @_context and @_old_context as before
          context = @_context
          old_context = @_old_context
          run_context pane_contents[:commands], &block
          clean_up_context(context, old_context)
        else
          pane_contents[:is_first_lvl_pane] = true
          run_context pane_contents, &block
        end
      else
        panes[pane_name] = { :commands => args }
      end
    end

    # Returns yaml file as Terminitor formmatted hash
    #
    # @return [Hash] Return hash format of Termfile
    #
    # @api semipublic
    def to_hash
      { :setup => @_setup, :windows => @_windows }
    end

    private

    # Execute the context
    #
    # @param [Hash] context
    #   hash of current context.
    # @param [Proc] block
    #   the context's block to be executed
    #
    # @example
    #   run_context @_setup, &block
    #   run @tabs['name'], &block
    #
    # @api private
    def run_context(context, &block)
      @_context, @_old_context = context, @_context
      instance_eval &block
      @_context = @_old_context
    end

    def clean_up_context(context = last_open_window, old_context = nil)
      @_context = context
      @_old_context = old_context
    end

    def last_open_window
      @_windows[@_windows.keys.last]
    end

    # Return the default hash format for windows
    #
    # @api private
    def window_hash
      {:tabs => {'default' =>{:commands=>[]}}}.dup
    end
  end
end
