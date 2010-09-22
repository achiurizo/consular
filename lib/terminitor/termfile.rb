module Terminitor
  class Termfile

    def initialize(path)
      file = File.read(path)
      @setup = []
      @windows = { 'default' => {}}
      @_context = @windows['default'] 
      instance_eval(file)
    end

    def setup(*commands, &block)
      setup_tasks = @setup
      if block_given?
        @_context, @_old_context = setup_tasks, @_context
        instance_eval(&block)
        @_context = @_old_context
      else
        setup_tasks.concat(commands)
      end
    end

    def window(name = nil, &block)
      window_tabs = @windows[name || "window#{@windows.keys.size}"] = {}
      @_context, @_old_context = window_tabs, @_context
      instance_eval(&block)
      @_context = @_old_context
    end

    def run(command)
      @_context << command
    end

    def tab(name= nil, *commands, &block)
      if block_given?
        tab_tasks = @_context[name || "tab#{@_context.keys.size}"] = []
        @_context, @_old_context = tab_tasks, @_context
        instance_eval(&block)
        @_context = @_old_context
      else
        tab_tasks = @_context["tab#{@_context.keys.size}"] = []
        tab_tasks.concat([name] + commands)
      end
    end

    def to_hash
      { :setup => @setup, :windows => @windows }
    end


    private

    #
    # in_context @setup, commands, &block
    # in_context @tabs["name"], commands, &block
    def in_context(tasks_instance,*commands, &block)
      if block_given?
        @_context, @_old_context = instance_variable_get(name), @_context
        instance_eval(&block)
        @_context = @_old_context
      else
        @setup << commands
      end
    end


  end
end
