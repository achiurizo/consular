module Terminitor
  module Runner

    # opens doc in system designated editor
    def open_in_editor(path)
      `#{ENV['EDITOR']} #{path}`
    end

    def do_project(path)
      terminal = app('Terminal')
      tabs = load_config(path)

      tabs.each do |hash|
        tabname = hash.keys.first
        cmds = hash.values.first

        tab = self.open_tab(terminal)
        cmds = [cmds].flatten
        cmds.each do |cmd|
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
      local_tabs = local_window.tabs if local_window
      local_tabs.last.get if local_tabs
    end

    # makes sure to set active window as frontmost.
    def active_window(terminal)
      (1..terminal.windows.count).each do |i|
        window = terminal.windows[i]
        return window if window.properties_.get[:frontmost]
      end
    end
  end
end
