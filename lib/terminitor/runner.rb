module Terminitor
  # This module contains all the helper methods for the Cli component.
  module Runner

    # Terminitor Global Path
    TERM_PATH = File.join(ENV['HOME'],'.config','terminitor')

    # Finds the appropriate platform core, else say you don't got it.
    # @param [String] the ruby platform
    # @example
    #   find_core RUBY_PLATFORM
    def find_core(platform)
      core = case platform.downcase
      when %r{darwin} then 
        if ENV['TERM_PROGRAM'] == 'iTerm.app'
          Terminitor::ItermCore
        else
          Terminitor::MacCore
        end
      when %r{linux}  then
       if not `which terminator`.chomp.empty?
         Terminitor::TerminatorCore
       else
         Terminitor::KonsoleCore # TODO silly fallback, make better check
       end
      when %r{mswin|mingw} then
        Terminitor::CmdCore
      else nil
      end
    end
    
    # Defines how to capture terminal settings on the specified platform
    # @param [String] the ruby platform
    def capture_core(platform)
      core = case platform.downcase
      when %r{darwin} then 
        if ENV['TERM_PROGRAM'] == 'iTerm.app'
          Terminitor::ItermCapture
        else
          Terminitor::MacCapture
        end
      when %r{linux}  then
        if not `which terminator`.chomp.empty?
          Terminitor::TerminatorCapture
        else
          Terminitor::KonsoleCapture # TODO silly fallback, make better check
        end
      else nil
      end
    end

    # Execute the core with the given method.
    # @param [Symbol] symbol of method
    # @param [String] Termfile name
    # @example
    #   execute_core :process!, 'project'
    #   execute_core :setup!, 'my_project'
    def execute_core(method, project)
      if path = resolve_path(project)
        core = find_core(RUBY_PLATFORM)
        core ? core.new(path).send(method) : say("No suitable core found!")
      else
        return_error_message(project)
      end
    end

    # opens doc in system designated editor
    # @param [String] path to termfile
    # @param [String] editor
    # @example
    #   open_in_editor '/path/to', 'nano'
    def open_in_editor(path, editor=nil)
      editor = editor || ENV['TERM_EDITOR'] || ENV['EDITOR']
      say "please set $EDITOR or $TERM_EDITOR in your .bash_profile." unless editor
      system("#{editor || 'open'} #{path}")
    end

    # returns path to file
    # @param [String] Termfile name
    # @example resolve_path 'my_project'
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
    # @param [String] Termfile path
    # @example grab_comment_for_file '/path/to'
    def grab_comment_for_file(file)
      first_line = File.readlines(file).first
      first_line =~ /^\s*?#/ ? ("-" + first_line.gsub("#","")) : "\n"
    end

    # Return file in config_path
    # @param [String] Termfile path
    # @param [Symbol] Type of file
    # @example config_path '/path/to', :term
    def config_path(file, type = :yml)
      return File.join(options[:root],"Termfile") if file.empty?
      if type == :yml
        File.join(TERM_PATH, "#{file.sub(/\.yml$/, '')}.yml")
      else
        File.join(TERM_PATH, "#{file.sub(/\.term$/, '')}.term")
      end
    end

    # Returns error message depending if project is specified
    # @param [String] Termfile name
    # @example return_error_message 'hi
    def return_error_message(project)
      unless project.empty?
        say "'#{project}' doesn't exist! Please run 'terminitor edit #{project.gsub(/\..*/,'')}'"
      else
        say "Termfile doesn't exist! Please run 'terminitor edit' in project directory"
      end
    end

    # This will clone a repo in the current directory.
    # It will first try to clone via ssh(read/write),
    # if not fall back to git-read only, else, fail.
    # @param [String] Github username
    # @param [String] Github project name
    # @example github_clone 'achiu', 'terminitor'
    def github_clone(username, project)
      github = `which github`
      return false if github.empty?
      command = "github clone #{username} #{project}"
      system(command + " --ssh") || system(command)
    end

    # Fetch the git repo and run the setup block
    # @param [String] Github username
    # @param [String] Github project
    # @param [Hash] options hash
    # @example fetch_repo 'achiu', 'terminitor', :setup => true
    def github_repo(username, project, options ={})
      if github_clone(username, project)
        path = File.join(Dir.pwd, project)
        FileUtils.cd(path)
        invoke(:setup, []) if options[:setup]
      else
        say("could not fetch repo!")
      end
    end

  end
  
end
