require 'active_support/ordered_hash'
require 'active_support/core_ext/array/extract_options'
require 'yaml'

module Consular

  # The DSL class provides the DSL for the Consular scripting file.
  # It provides the basic commands such as:
  #   #setup  - commands to run when invoked by 'consular setup'
  #   #window - commands to run in the context of a window
  #   #tab    - commands to run in the context of tab
  #   #before - commands to run in the context before every tab context
  #
  # The DSL class can be extended to provide additional API's for core specific
  # DSL.
  class DSL

    attr_reader :_setup, :_windows, :_context

    # Initializes the DSL library and stores the commands.
    #
    # @param [String] path
    #   path to Consular script/ Termfile
    #
    # @example
    #   Consular::DSL.new 'foo/bar.term'
    #
    # @api public
    def initialize(path)
      @_setup              = []
      @_windows            = ActiveSupport::OrderedHash.new
      @_windows['default'] = window_hash
      @_context            = @_windows['default']
      file = File.read(path)
      if path =~ /\.yml$/
        @_file = YAML.load file
        extend Yaml
      else
        instance_eval file, __FILE__, __LINE__
      end
    end

    # Run commands using prior to the workflow using the command `consular setup`.
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
    # @param [Array] args
    #   Hash to pass options to each context of a window. Each core can
    #   implement the desired behavior for the window based on the options set here.
    #   Can also pass a string as first parameter which will be set as
    #   the :name
    # @param [Proc] block
    #   block of commands to run in window context.
    #
    # @example
    #   window 'my project', :size => [80, 30] do
    #     run 'ps aux'
    #   end
    #
    # @api public
    def window(*args, &block)
      key            = "window#{@_windows.keys.size}"
      options        = args.extract_options!
      options[:name] = args.first unless args.empty?
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
    #   tab 'first tab', :settings => 'Grass' do
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
      options           = args.extract_options!
      options[:name]    = args.first unless args.empty?
      context[:options] = options

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


    # Returns yaml file as Consular formmatted hash
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

    module Yaml
      # Returns yaml file as formmatted hash
      #
      # @return [Hash] Hash format of Termfile
      #
      # @api public
      def to_hash
        @_file ||= {}
        combined = @_file.inject({}) do |base, item| 
          item = {item.keys.first => {:commands => item.values.first, :options => {}}}
          base.merge!(item)
          base
        end # merge the array of hashes.
         { :setup => nil, :windows => { 'default' => { :tabs => combined } } }
      end
    end
  end
end
