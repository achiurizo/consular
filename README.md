Terminitor
===========

Terminitor automates your development workflow setup. Less time setting up, more time getting things done.

Upgrading Terminitor from 0.4.1 and under
------------------------------------------

For those upgrading from Terminitor 0.4.1, please run:

    $ terminitor update

This will move your terminitor files to the new directory located at .config/terminitor 

Installation
------------

    $ gem install terminitor
    $ terminitor init

Development Setup
---------------------

To begin development on Terminitor, run bundler:

    $ gem install bundler
    $ bundle install

The test suite uses ([Riot](https://www.github.com/thumblemonks/riot/)).
to run the test run:

    $ rake test

or use watchr:

    $ watchr test.watchr

or if you have terminitor installed,

    $ terminitor fetch achiu terminitor

this will git clone the repo and bundle install.

Usage
-------

### Creating Local Projects ###

Using terminitor is quite easy. To define or edit a project file, simply invoke the command:

    $ terminitor edit foo

This will open your default editor (set through the $TERM_EDITOR or $EDITOR variable in BASH) and you can proceed to define the commands for that project with the following syntaxes:

#### YAML Syntax ( Legacy ) ####
    
    # ~/.config/terminitor/foo.yml
    # you can make as many tabs as you wish...
    # tab names are actually arbitrary at this point too.
    ---
    - tab1:
      - cd ~/foo/bar
      - gitx
    - tab2:
      - mysql -u root)
      - use test;
      - show tables;
    - tab3: echo "hello world"
    - tab4: cd ~/baz/ && git pull
    - tab5:
      - cd ~/foo/project
      - autotest

Simply define each tab and declare the commands. Note that the session for each tab is maintained, so you just declare actions here as
you would manually type in the terminal. Note that the title for each tab(namely tab1, tab2) are arbitrary, and can be named whatever you want.
They are simply placeholders for the time being for upcoming features.

To use the legacy syntax, you can invoke it with terminitor like so:

    $ terminitor edit foo --syntax yml

It is recommended that you move over to the newer Ruby DSL Syntax as it
provides more robust features, however terminitor will still support the older
YAML syntax.


#### Ruby DSL Syntax ####

````ruby
setup 'echo "setup"'   # code to run during setup

# open a tab in current window with these commands
tab "echo 'default'", "echo 'default tab'"

window do
  before { run 'cd /path' } # run this command before each command.
  
  run 'padrino start' # run in new window

  tab "echo 'first tab'", "echo 'of window'" # create a new tab in window and run it.
  tab "named tab" do
    run "echo 'named tab'"
    run "ls"
  end
end
````

The newer Ruby DSL syntax allows for more complicated behavior such as window creation as well as setup blocks that can be executed prior loading a project.

##### Tabs #####

to create tabs, we can simply invoke the tab command with either the command arguments like:

````ruby
tab "echo 'hi'", "gitx"
````

or even pass it a block:

````ruby
tab do
  run "echo 'hi'"
  run "mate ."
end
````

##### Windows #####

to create windows, we can simply invoke the window command with a block containing additional commands like:

````ruby
window do

  run "whoami"    # Runs the command in the current window.

  tab "echo 'hi'" # Creates another tab
  tab "mate ."    # And another
  tab do          # Last hoorah
    run "open http://www.google.com"
  end
end
````

##### Before #####

Sometimes you'll want to create a few commands that you want to run in each tab instance. You can do that with 'before':

````ruby
before { run "cd /path" } # execute this command before other commands in the default window
run "whoami"
tab 'uptime'

# In this instance, "cd /path" wil be executed in the default window before 'whoami' 
# and also in the tab before 'uptime'.
# You can also use this inside a specific window context:

window do
  before 'cd /tmp'
  run 'watchr test.watchr' # "cd /tmp" first than run watchr

  tab do
    run 'padrino start' # "cd /tmp" is ran beforehand and then padrino start is executed
  end
end
````



##### Setup #####

The setup block allows you to store commands that can be ran specifically before a project and can be defined with:

the command arguments:

````ruby
setup "bundle install", "gitx"
````
    
or with a block:

````ruby
setup do
  run "echo 'hi'"
  run "bundle install"
  run 'git remote add upstream git://github.com/achiu/terminitor.git'
end
````


Once defined, you can invoke your projects setup with:

    terminitor setup my_project

##### Settings #####
_currently only available for Mac OSX Terminal_

You can also set settings on each of your tabs and windows. for example, this is possible:

Open a tab with terminal settings "Grass"

````ruby
tab :name => "named tab", :settings => "Grass" do
  run "echo 'named tab'"
  run "ls"
end
````

This will create a tab with a title of 'named tab' using Terminals 'Grass' setting.


How about a window with a specific size:

````ruby
window :bounds => [10,20,300,200] do

end
````

Currently, the following options are available:

__tabs__

* :settings     - [String]  Set the tab to terminal settings
* :selected     - [Boolean] Sets whether the tab is active
* :miniaturized - [Boolean] Sets whether its miniaturized
* :visible      - [Boolean] Sets whether its visible


__windows__

* :bounds       - [Array]  Sets the bounds
* :miniaturized - [Boolean] Sets whether its miniaturized
* :visible      - [Boolean] Sets whether its visible

### Running Terminitor Projects ###

Once the project file has been declared to your satisfaction, simply execute any project defined in the `~/.config/terminitor` directory with:

    $ terminitor start foo

This will execute the steps and create the tabs defined and run the various options as expected. That's it. Create as many project files with as many tabs
as you would like and automate your workflow.

### Removing Terminitor Projects ###

If you no longer need a particular project, you can easily remove the terminitor file for the project:

    $ terminitor delete foo
    
to remove a legacy yml syntax file you can run:

    $ terminitor delete foo -s=yml


### Listing Terminitor Projects ###

You can also see a full list of available projects with:

    $ terminitor list

This will print out the available project files that you can execute. The list also returns whatever text you have in the first comment of each terminitor script.

### Creating Termfile for Repo ###

In addition to creating 'local' projects which can run on your computer (and are stored in your home directory), we also
optionally allow you to create a `Termfile` within any directory and then you can execute this any time to setup the
environment for that particular project source.

For example, let's say I am in `/code/my/foo/project` directory which is
a Sinatra application. This application might have a `Gemfile` which includes all dependencies. You can also generate a `Termfile`
which contains the ideal development setup for OSX. To generate this file, invoke:

    $ terminitor create

This will generate a 'Termfile' in the current project directory and open the file to be edited in the default text editor. The format
of the file is using the new Ruby DSL as described above in the previous section. You should *note* that the project directory is automatically
the working directory for each tab so you can just say `mate .` and the project directory containing the `Termfile` will open.

Now, when you or another developer clones a project, you could simply:

    $ git clone git://path/to/my/foo/project.git
    $ cd project
    $ terminitor setup
    $ terminitor start

This would clone the project repo, and then install all dependencies and then launch the ideal development environment for the project. Clearly
this makes assumptions about the user's system setup right now, but we have some ideas on how to make this work more effectively on
different configurations in the future.

In addition, you are in the project folder and you wish to remove the Termfile, you can invoke the command:

    $ terminitor delete

This will clear the `Termfile` for the particular project.

### Capturing Terminal Settings with Terminitor ###
_Currently Mac OSX Terminal only_
Terminitor has the ability to also capture your terminal setup and settings simply with:

    $ terminitor edit my_project --capture
    
this will open up a new terminitor project with the captured settings for you to continuing modifying as you see fit.


### Fetching Github Projects with Terminitor ###

Terminitor can also fetch code repositories off Github. This will have terminitor clone the repo into the current directory:

    $ terminitor fetch achiu terminitor

After the repo has been fetched, terminitor will go ahead and run the setup block from the Termfile included in the repository. In the event you wouldn't want the setup block to be executed, simply set setup to false:

    $ terminitor fetch achiu terminitor --setup=false

Some notes. Terminitor's fetch command is dependent on the ([github-gem](http://github.com/defunkt/github-gem)) at the current moment. It will try to fetch the repository with read/write access first if you have rights, if not, it will default to git read only. Happy fetching!


Cores
-----

Cores allow Terminitor to operate on a variety of platforms. They abstract the general behavior that terminitor needs to run the commands. Each core would inherit from an ([AbstractCore](http://github.com/achiu/terminitor/blob/master/lib/terminitor/abstract_core.rb)) and define the needed methods. At the moment the following Cores are supported:

 * MacCore        - Mac OS X Terminal
 * KonsoleCore    - KDE Konsole
 * TerminatorCore - [Terminator](http://www.tenshu.net/terminator/)
 * ITermCore      - Mac OS X iTerm

Feel free to contribute more cores so that Terminitor can support your terminal of choice :)


Limitations
-----------

#### MacCore ####

Right now the Mac OS X Terminal tabs are created by invoking keystrokes which means there are limitations with the terminal being in
focus during execution of these commands. Obviously the long term goal is to solve this issue as well but in all honesty, this solution works well enough most of the time.


#### ITermCore ####

Currently the iTerm Core only provides basic functionality such as opening tabs, windows, and executing commands within them. It is also possible to split tabs into panes. The capture
and settings functionality will be integrated soon.

Splitting tabs into panes works as follows:

    tab do
      pane "gitx" # first pane
        pane do      # second pane level => horizontal split
          run "irb"
        end
      pane 'ls'   # first pane level => vertical split
    end

should result into something like this:

    #    ###########################
    #    #            #            #
    #    #            #            #
    #    #   'gitx'   #            #
    #    #            #            #
    #    #            #            #
    #    ##############    'ls'    #
    #    #            #            #
    #    #            #            #
    #    #   'irb'    #            #
    #    #            #            #
    #    #            #            #
    #    ###########################

It is not possible to split the second level panes (the horizontal
ones). Nevertheless you should be able to split tabs into any kind of pane pattern you wish
with this syntax.


#### Fetching ####

The fetch task only pulls off Github repositories at the moment. Later on, this functionality will be extended to non github repository.


#### Settings and Captures ####

This feature is currently only available in Mac OS X at the moment.


#### Terminator support ####

This feature currently requires the "xdotool" utility to be installed and in
the search path. The xdotool homepage is
http://www.semicomplete.com/blog/projects/xdotool/.


#### Windows suppport ####

Windows support is currently limited to plain cmd.exe. It is also
limited to only creating new windows, as cmd.exe does not support tabs.


Authors
-------

The core code was adapted before by Nathan Esquenazi and Thomas Shafer.
In September 2010, Arthur Chiu and Nathan Esquenazi gemified and released this to gemcutter.

Contributors
-------------

Thanks to the following people for their contributions so far:

 * Pat George      ([pcg79](https://github.com/pcg79)) for contributing a patch for when a project is not found.
 * Tim Gossett     ([[MrGossett](https://github.com/MrGossett)) for a patch to fix comment reading
 * Flavio Castelli ([flavio](https://github.com/flavio)) for contributing Konsole(KDE) core.
 * Alexey Kuleshov ([kulesa](https://github.com/kulesa)) for contributing the terminal settings and terminal settings capture functionality
 * Arthur Gunn     ([gunn](https://github.com/gunn)) for contributing a path to support tab syntax and load path.
 * Elliot Winkler  ([mcmire](https://github.com/mcmire)) for adding 1.8.6 compatiblity and ensuring tabs open in order and fixing named tabs
 * Justin Hilemen  ([bobthecow](https://github.com/bobthecow)) for fixing the list command to remove the term extensions.
 * Dave Perrett    ([recurser](https://github.com/recurser)) for adding basic iTerm support.
 * Ilkka Laukkanen ([ilkka](https://github.com/achiu/terminitor/commits/master?author=ilkka)) for Terminator core and other fixes
 * Elia Schito     ([elia](https://github.com/achiu/terminitor/commits/master?author=elia)) for patch to allow usage of "&" for background operations
 * Dotan J. Nahum  ([jondot](https://github.com/jondot)) for adding windows(cmd.exe) support
 * Kyriacos Souroullas ([kyriacos](https://github.com/kyriacos) For removing params to support generic commands
 * Jerry Cheung ([jch](https://github.com/jch)) For adding ignore for emac backups

Acknowledgements
-----------------



The core terminal scripting code was initially developed by [Jeff Emminger](http://workingwithrails.com/person/2412-jeff-emminger) years ago. The original introduction was made on the [ELCTech Blog](http://blog.elctech.com/2008/01/16/script-terminal-with-terminit/) and a lot of that code was adapted from [Scripting the Terminal in Leopard](http://onrails.org/articles/2007/11/28/scripting-the-leopard-terminal).

This was a great start and made terminal automation easy. However, the repository died long ago, and we had continued using the code for a while.
Finally, we decided the time had come to release this code back to the world as a gem. Thanks to ELC for creating the original source for this project.

Also, we didn't take any code from [Project](http://github.com/joshnesbitt/project) by Josh but that project did inspire us to setup terminit
as a gem. Basically, project is a great gem but there were a couple issues with the fact that the terminal doesn't save the session state in some cases.
I had already been using terminit for years so we decided to package this up for easy use.
