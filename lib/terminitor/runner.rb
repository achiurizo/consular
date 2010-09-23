module Terminitor
  module Runner

    # opens doc in system designated editor
    def open_in_editor(path, editor=nil)
      editor = editor || ENV['TERM_EDITOR'] || ENV['EDITOR']
      say "please set $EDITOR or $TERM_EDITOR in your .bash_profile." unless editor
      system("#{editor || 'open'} #{path}")
    end

    def do_project(path)
      terminal = app('Terminal')
      tabs = load_config(path)

      tabs.each do |hash|
        tabname = hash.keys.first
        cmds = hash.values.first

        tab = self.open_tab(terminal)
        cmds = [cmds].flatten
        cmds.insert(0, "cd \"#{@working_dir}\" ; clear") unless @working_dir.to_s.empty?
        cmds.each do |cmd|
          terminal.windows.last.do_script(cmd, :in => tab)
        end
      end
    end

    def run_termfile(path)
      terminal = app('Terminal')
      termfile = load_termfile(path)
      setups = termfile[:setup]
      windows = termfile[:windows]
      puts termfile.inspect
      unless windows['default'].empty?
        default = windows.delete('default')
        run_in_window default, terminal, :default => true
      end
      windows.each_pair { |window_name, tabs| puts "w: #{window_name}" ; run_in_window(tabs, terminal) }

    end

    # this command will run commands in the designated window
    def run_in_window(tabs, terminal, options = {})
      self.open_window(terminal) unless options[:default]
      tabs.each_pair do |tab_name,commands|
        puts tab_name
        tab = self.open_tab(terminal)
        commands.insert(0,  "cd \"#{@working_dir}\"") unless @working_dir.to_s.empty?
        commands.each do |cmd|
          puts "  - #{cmd}"
          terminal.windows.last.do_script(cmd, :in => tab)
        end
      end

    end

    def resolve_path(project)
      unless project.empty?
        File.join(ENV['HOME'],'.terminitor', "#{project.sub(/\.yml$/, '')}.yml")
      else
        File.join(options[:root],"Termfile")
      end
    end

    def load_config(path)
      YAML.load(File.read(path))
    end

    def load_termfile(path)
      Terminitor::Termfile.new(path).to_hash
    end

    # somewhat hacky in that it requires Terminal to exist,
    # which it would if we run this script from a Terminal,
    # but it won't work if called e.g. from cron.
    # The latter case would just require us to open a Terminal
    # using do_script() first with no :in target.
    #
    # One more hack:  if we're getting the first tab, we return
    # the term window's only current tab, else we send a CMD+T
    def open_tab(terminal)
      if @got_first_tab_already
        app("System Events").application_processes["Terminal.app"].keystroke("t", :using => :command_down)
      end
      @got_first_tab_already = true
      local_window = active_window(terminal)
      @working_dir = Dir.pwd
      local_tabs = local_window.tabs if local_window
      local_tabs.last.get if local_tabs
    end

    def open_window(terminal)
      app("System Events").application_processes["Terminal.app"].keystroke("n", :using => :command_down)
      sleep 2
      local_window = active_window(terminal)
      local_window.activate
      local_tabs = local_window.tabs if local_window
      local_tabs.last.get if local_tabs
    end


    # makes sure to set active window as frontmost.
    def active_window(terminal)
      (1..terminal.windows.count).each do |i|
        window = terminal.windows[i]
        return window if window && window.properties_.get[:frontmost]
      end
    end
  end
end
