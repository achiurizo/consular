Terminitor
===========

Terminitor automates your development workflow by allowing you to script the commands to run in your terminal to begin working on a given project.

Installation
------------


    $ gem install terminitor
    $ terminit setup

Usage
-------

Using terminitor is quite easy. First define your project files:

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
you would manually in terminal.

Once the project file has been declared, simply execute any project defined in the @.terminit@ directory with:

    $ terminit foo

This will execute the steps and create the tabs defined and run the various options as expected. That's it. Create as many project files with as many tabs
as you would like and automate your workflow.

Limitations
-----------

This only works on OS X because of the dependency on applescript. It would presumably not be impossible to port this to Linux or Windows, and
of course patches and suggestions are welcome.


Acknowledgements
-----------------

This code came originally years ago from: http://blog.elctech.com/2008/01/16/script-terminal-with-terminit/ .
This was a great start and made terminal automation easy. However, the repository is dead, but we had continued using the code for a while.
Finally, we decided the time had come to release this code back to the world as a gem. Thanks to ELC for creating the original
source for this project.