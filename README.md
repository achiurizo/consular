Terminitor
===========

Terminitor automates your development workflow by allowing you to script the commands to run in your terminal to begin working on a given project.

Installation
------------

    $ gem install terminitor
    $ terminitor setup

Usage
-------

### Creating Local Projects ###

Using terminitor is quite easy. To define or edit a project file, simply invoke the command:

    $ terminitor open foo

This will open your default editor (set through the $EDITOR variable in BASH) and you can proceed to define the commands for that project:

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

Once the project file has been declared to your satisfaction, simply execute any project defined in the `~/.terminitor` directory with:

    $ terminitor start foo

This will execute the steps and create the tabs defined and run the various options as expected. That's it. Create as many project files with as many tabs
as you would like and automate your workflow.

If you no longer need a particular project, you can easily remove the yml file for the project:

    $ terminitor delete foo

You can also see a full list of available projects with:

    $ terminitor list

This will print out the available project files that you can execute.

### Creating Termfile for Repo ###

In addition to creating 'local' projects which can run on your computer (and are stored in your home directory), we also
optionally allow you to create a `Termfile` within any directory and then you can execute this any time to setup the
environment for that particular project source.

For example, let's say I am in `/code/my/foo/project` directory which is
a Sinatra application. This application might have a `Gemfile` which includes all dependencies. You can also generate a `Termfile`
which contains the ideal development setup for OSX. To generate this file, invoke:

    $ terminitor create

This will generate a 'Termfile' in the current project directory and open the file to be edited in the default text editor. The format
of the file is still YAML as described above in the previous section. You should *note* that the project directory is automatically
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

Limitations
-----------

This only works on OS X because of the dependency on applescript. It would presumably not be impossible to port this to Linux or Windows, and
of course patches and suggestions are welcome.

Another issue is that right now tabs are created by invoking keystrokes which means there are limitations with the terminal being in
focus during execution of these commands. Obviously the long term goal is to solve this issue as well but in all honesty,
this solution works well enough most of the time.

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