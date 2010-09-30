module Terminitor
  # This module contains all the helper methods for the Cli component.
  module Runner

    # Finds the appropriate platform core, else say you don't got it.
    # find_core RUBY_PLATFORM
    def find_core(platform)
      core = case platform.downcase
      when %r{darwin} then Terminitor::MacCore
      when %r{linux}  then Terminitor::KonsoleCore # TODO check for gnome and others
      else nil
      end
    end

    # Execute the core with the given method.
    # execute_core :process!, 'project'
    # execute_core :setup!, 'my_project'
    def execute_core(method, project)
      if path = resolve_path(project)
        core = find_core(RUBY_PLATFORM)
        core ? core.new(path).send(method) : say("No suitable core found!")
      else
        return_error_message(project)
      end
    end

    # opens doc in system designated editor
    # open_in_editor '/path/to', 'nano'
    def open_in_editor(path, editor=nil)
      editor = editor || ENV['TERM_EDITOR'] || ENV['EDITOR']
      say "please set $EDITOR or $TERM_EDITOR in your .bash_profile." unless editor
      system("#{editor || 'open'} #{path}")
    end

    # returns path to file
    # resolve_path 'my_project'
    def resolve_path(project)
      unless project.empty?
        path = config_path(project, :yml) # Give old yml path
        return path if File.exists?(path)
        path = config_path(project, :term) # Give new term path.
        return path if File.exists?(path)
        nil
      else
        path = File.join(options[:root],"Termfile")
        return path if File.exists?(path)
        nil
      end
    end

    # returns first line of file
    # grab_comment_for_file '/path/to'
    def grab_comment_for_file(file)
      first_line = File.readlines(file).first
      first_line =~ /^\s*?#/ ? ("-" + first_line.gsub("#","")) : "\n"
    end

    # Return file in config_path
    # config_path '/path/to', :term
    def config_path(file, type = :yml)
      return File.join(options[:root],"Termfile") if file.empty?
      dir = File.join(ENV['HOME'],'.terminitor')
      if type == :yml
        File.join(dir, "#{file.sub(/\.yml$/, '')}.yml")
      else
        File.join(dir, "#{file.sub(/\.term$/, '')}.term")
      end
    end

    # Returns error message depending if project is specified
    # return_error_message 'hi
    def return_error_message(project)
      unless project.empty?
        say "'#{project}' doesn't exist! Please run 'terminitor open #{project.gsub(/\..*/,'')}'"
      else
        say "Termfile doesn't exist! Please run 'terminitor open' in project directory"
      end
    end

    # This will clone a repo in the current directory.
    # It will first try to clone via ssh(read/write),
    # if not fall back to git-read only, else, fail.
    def clone_repo(username, project)
      github = `which github`
      return false if github.empty?
      command = "github clone #{username} #{project}"
      system(command + " --ssh") || system(command)
    end

    # Fetch the git repo and run the setup block
    # fetch_repo 'achiu', 'terminitor', :setup => true
    def fetch_repo(username, project, options ={})
      if clone_repo(username, project)
        path = File.join(Dir.pwd, project)
        FileUtils.cd(path)
        invoke(:setup, []) if options[:setup]
      else
        say("could not fetch repo!")
      end
    end

  end
end
