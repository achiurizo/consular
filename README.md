Terminitor
===========

Terminitor automates your development workflow by allowing you to script the commands to run in your terminal to begin working on a given project.

Installation
------------

    $ gem install terminitor
    $ terminitor init

Usage
-------

### Creating Local Projects ###

Using terminitor is quite easy. To define or edit a project file, simply invoke the command:

    $ terminitor edit foo

This will open your default editor (set through the $TERM_EDITOR or $EDITOR variable in BASH) and you can proceed to define the commands for that project with the following syntaxes:

#### YAML Syntax ( Legacy ) ####
    
    # ~/.terminitor/foo.yml
    # you can make as many tabs as you wish...
    # tab names are actually arbitrary at this point too.
    ---
    - tab1:
      - cd ~/foo/bar
      - gitx
    - tab2:
      - mysql -u root
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


#### Ruby DSL Syntax ####

    setup 'echo "setup"'

    tab "echo 'default'", "echo 'default tab'"

    window do
      tab "echo 'first tab'", "echo 'of window'"
  
      tab "named tab" do
        run "echo 'named tab'"
        run "ls"
      end
    end

The newer Ruby DSL syntax allows for more complicated behavior such as window creation as well as setup blocks that can be executed prior loading a project.

##### Tabs #####

to create tabs, we can simply invoke the tab command with either the command arguments like:

    tab "echo 'hi'", "gitx"
    
or even pass it a block:

    tab do
      run "echo 'hi'"
      run "mate ."
    end

##### Windows #####

to create windows, we can simply invoke the window command with a block containing additional commands like:

    window do
      tab "echo 'hi'"
      tab "mate ."
      tab do
        run "open http://www.google.com"
      end
    end

##### Setup #####

The setup block allows you to store commands that can be ran specifically before a project and can be defined with:

the command arguments:

    setup "bundle install", "gitx"
    
or with a block:

    setup do
      run "echo 'hi'"
      run "bundle install"
    end


### Running Terminitor Projects ###

Once the project file has been declared to your satisfaction, simply execute any project defined in the `~/.terminitor` directory with:

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
    $ bundle install
    $ terminitor start

This would clone the project repo, and then install all dependencies and then launch the ideal development environment for the project. Clearly
this makes assumptions about the user's system setup right now, but we have some ideas on how to make this work more effectively on
different configurations in the future.

In addition, you are in the project folder and you wish to remove the Termfile, you can invoke the command:

    $ terminitor delete

This will clear the `Termfile` for the particular project.


### Fetching Github Projects with Terminitor ###

Terminitor can also fetch code repositories off Skynet, I mean Github. This will have terminitor clone the repo into the current directory:

    $ terminitor fetch achiu terminitor
    
After the repo has been fetched, terminitor will go ahead and run the setup block from the Termfile included in the repository. In the event you wouldn't want the setup block to be executed, simply set setup to false:

    $ terminitor fetch achiu terminitor --setup=false

Some notes. Terminitor's fetch command is dependent on the ([github-gem](http://github.com/defunkt/github-gem)) at the current moment. It will try to fetch the repository with read/write access first if you have rights, if not, it will default to git read only. Happy fetching!


Cores
-----

Cores allow Terminitor to operate on a variety of platforms. They abstract the general behavior that terminitor needs to run the commands. Each core would inherit from an ([AbstractCore](http://github.com/achiu/terminitor/blob/master/lib/terminitor/abstract_core.rb)) and define the needed methods. At the moment the following Cores are supported:

 * MacCore        - Mac OS X Terminal
 * KonsoleCore    - KDE Konsole

Feel free to contribute more cores so that Terminitor can support your terminal of choice :)


Limitations
-----------

#### MacCore ####

Right now the Mac OS X Terminal tabs are created by invoking keystrokes which means there are limitations with the terminal being in
focus during execution of these commands. Obviously the long term goal is to solve this issue as well but in all honesty,
this solution works well enough most of the time.

#### Fetching ####

The fetch task only pulls off Github repositories at the moment(which is cool). Later on, this functionality will be extended to non github repository(probably later this week.)

Authors
-------

The core code was adapted before by Nathan Esquenazi and Thomas Shafer.
In September 2010, Arthur Chiu and Nathan Esquenazi gemified and released this to gemcutter.

Contributors
-------------

Thanks to the following people for their contributions so far:

 * Pat George ([pcg79](http://github.com/pcg79)) for contributing a patch for when a project is not found.
 * Flavio Castelli ([flavio](http://github.com/flavio)) for contributing Konsole(KDE) core.

Acknowledgements
-----------------



The core terminal scripting code was initially developed by [Jeff Emminger](http://workingwithrails.com/person/2412-jeff-emminger) years ago. The original introduction was made on the [ELCTech Blog](http://blog.elctech.com/2008/01/16/script-terminal-with-terminit/) and a lot of that code was adapted from [Scripting the Terminal in Leopard](http://onrails.org/articles/2007/11/28/scripting-the-leopard-terminal).

This was a great start and made terminal automation easy. However, the repository died long ago, and we had continued using the code for a while.
Finally, we decided the time had come to release this code back to the world as a gem. Thanks to ELC for creating the original source for this project.

Also, we didn't take any code from [Project](http://github.com/joshnesbitt/project) by Josh but that project did inspire us to setup terminit
as a gem. Basically, project is a great gem but there were a couple issues with the fact that the terminal doesn't save the session state in some cases.
I had already been using terminit for years so we decided to package this up for easy use.