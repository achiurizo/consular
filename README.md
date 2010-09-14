Terminitor
===========

Terminitor automates your development workflow by allowing you to script the commands to run in your terminal to begin working on a given project.

Installation
------------

    $ gem install terminitor
    $ terminitor setup

Usage
-------

Using terminitor is quite easy. To define or edit a project file, simply invoke the command:

    $ terminitor open foo

This will open your default editor (set by the $EDITOR variable in BASH) and you can proceed to define the commands for that project:

    # ~/.terminit/foo.yml
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

Simply define the tabs and declare each command. Note that the session of each tab is maintained, so you just declare actions here as
you would manually type in the terminal. Note that the title for each tab(namely tab1, tab2) are arbitrary, and can be named whatever you want. They are simply placeholders

Once the project file has been declared to your satisfaction, simply execute any project defined in the @.terminit@ directory with:

    $ terminitor start foo

This will execute the steps and create the tabs defined and run the various options as expected. That's it. Create as many project files with as many tabs
as you would like and automate your workflow.

Limitations
-----------

This only works on OS X because of the dependency on applescript. It would presumably not be impossible to port this to Linux or Windows, and
of course patches and suggestions are welcome.

Authors
-------

The core code was adapted before by Nathan Esquenazi and Thomas Shafer. In September 2010, Arthur Chiu and Nathan Esquenazi gemified and released this to gemcutter.

Acknowledgements
-----------------

This code came originally years ago from: http://blog.elctech.com/2008/01/16/script-terminal-with-terminit/ .
This was a great start and made terminal automation easy. However, the repository is dead, but we had continued using the code for a while.
Finally, we decided the time had come to release this code back to the world as a gem. Thanks to ELC for creating the original
source for this project.

Also, we didn't take any code from [Project](http://github.com/joshnesbitt/project) by Josh but that project did inspire us to setup terminit
as a gem. Basically, project is a great gem but there were a couple issues with the fact that the terminal doesn't save the session state in some cases.
I had already been using terminit for years so we decided to package this up for easy use.