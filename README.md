Consular
===========
Formally known as *Terminitor*

Consular automates your development workflow setup. Less time setting up, more time getting things done.

WTFBBQ name change?
-------------------

There are a few reasons why the name change happened. To state it simply:

  * Terminitor apparently was a pretty difficult name to spell, was
    a bit awkward, and the 'i' appeared in a place you didn't expect.
  * It's a pretty long name to type.
  * console => consul(ar).


So what's new/different? let's start.

Setup && Installation
------------

Install the consular gem and `init`:

```bash
$ gem install consular
$ consular init
```

This will generate a global path directory for your scripts to live in
at `~/.config/consular` and also a `.consularc` in your home directory.
You can customize your Consular further with `.consularc`. Say for
example, that you didn't like the default global path:

```ruby
# ~/.consularc

Consular.configure do |c|
  c.global_path = '/a/path/i/like/better'
end
```


Development Setup
---------------------

To begin development on Consular, run bundler:

    $ gem install bundler
    $ bundle install

The test suite uses Minitest
to run the test run:

    $ rake test

or use watchr:

    $ watchr spec.watchr

Usage
-------

### Creating Local Projects ###

Using consular is quite easy. To define or edit a project file, simply invoke the command:

    $ consular edit foo

This will open your default editor (set through the $TERM_EDITOR or $EDITOR variable in BASH) and you can proceed to define the commands for that project with the following syntaxes:

#### YAML Syntax ( Legacy ) ####

```yaml
# ~/.config/consular/foo.yml
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
```

Simply define each tab and declare the commands. Note that the session for each tab is maintained, so you just declare actions here as
you would manually type in the terminal. Note that the title for each tab(namely tab1, tab2) are arbitrary, and can be named whatever you want.
They are simply placeholders for the time being for upcoming features.

To use the legacy syntax, you can invoke it with consular by appending
the 'yml' file extension like so:

    $ consular edit foo.yml

It is recommended that you move over to the newer Ruby DSL Syntax as it
provides more robust features, however consular will still support the older
YAML syntax.


#### Ruby DSL Syntax ####

````ruby
setup 'echo "setup"'   # code to run during setup

# open a tab in current window with these commands
tab "echo 'default'", "echo 'default tab'"

window do
  before { run 'cd /path' } # run this command before each command.

  # run in new window
  run 'padrino start'

  # create a new tab in window and run it.
  tab "echo 'first tab'", "echo 'of window'"

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
  run 'git remote add upstream git://github.com/achiu/consular.git'
end
````


Once defined, you can invoke your projects setup with:

    consular setup my_project

### Running Consular Projects ###

Once the project file has been declared to your satisfaction, simply execute any project defined in the `~/.config/consular` directory with:

    $ consular start foo

This will execute the steps and create the tabs defined and run the various options as expected. That's it. Create as many project files with as many tabs
as you would like and automate your workflow.

### Removing Consular Projects ###

If you no longer need a particular project, you can easily remove the consular file for the project:

    $ consular delete foo
    
to remove a legacy yml syntax file you can just append the file
extension and run:

    $ consular delete foo.yml


### Listing Consular Projects ###

You can also see a full list of available projects with:

    $ consular list

This will print out the available project files that you can execute. The list also returns whatever text you have in the first comment of each consular script.

### Creating Termfile for Repo ###

In addition to creating 'local' projects which can run on your computer (and are stored in your home directory), we also
optionally allow you to create a `Termfile` within any directory and then you can execute this any time to setup the
environment for that particular project source.

For example, let's say I am in `/code/my/foo/project` directory which is
a Sinatra application. This application might have a `Gemfile` which includes all dependencies. You can also generate a `Termfile`
which contains the ideal development setup for OSX. To generate this file, invoke:

    $ consular create

This will generate a 'Termfile' in the current project directory and open the file to be edited in the default text editor. The format
of the file is using the new Ruby DSL as described above in the previous section. 

Now, when you or another developer clones a project, you could simply:

    $ git clone git://path/to/my/foo/project.git
    $ cd project
    $ consular setup
    $ consular start

This would clone the project repo, and then install all dependencies and then launch the ideal development environment for the project. Clearly
this makes assumptions about the user's system setup right now, but we have some ideas on how to make this work more effectively on
different configurations in the future.

In addition, you are in the project folder and you wish to remove the Termfile, you can invoke the command:

    $ consular delete

This will clear the `Termfile` for the particular project.

Cores
-----

Cores allow Consular to operate on a variety of platforms. They abstract the general behavior that consular needs to run the commands. 
Each core inherits from ([Consular::Core](http://github.com/achiu/consular/blob/master/lib/consular/core.rb)) and defines the needed methods.
Some of the cores that are available are:

 * [OSX](http://www.github.com/achiu/consular-osx) - Mac OS X Terminal
 * [Terminator](https://github.com/ilkka/consular-terminator) - Terminator
 * [Gnome](https://github.com/jc00ke/consular-gnome-terminal) - Gnome Terminal

Feel free to contribute more cores so that Consular can support your terminal of choice :)

To integrate core support for your Consular, you can simply require it
in your `.consularc` like so:

```ruby
# .consularc
require 'consular/osx'
```

Or check the README of each individual core.

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
 * Ilkka Laukkanen ([ilkka](https://github.com/achiu/consular/commits/master?author=ilkka)) for Terminator core and other fixes
 * Elia Schito     ([elia](https://github.com/achiu/consular/commits/master?author=elia)) for patch to allow usage of "&" for background operations
 * Dotan J. Nahum  ([jondot](https://github.com/jondot)) for adding windows(cmd.exe) support
 * Kyriacos Souroullas ([kyriacos](https://github.com/kyriacos) for removing params to support generic commands
 * Jerry Cheung ([jch](https://github.com/jch)) for adding ignore for emac backups
 * Michael Klein ([LevelbossMike](https://github.com/LevelbossMike)) for adding iTerm Pane support

Acknowledgements
-----------------

The core terminal scripting code was initially developed by [Jeff Emminger](http://workingwithrails.com/person/2412-jeff-emminger) years ago. The original introduction was made on the [ELCTech Blog](http://blog.elctech.com/2008/01/16/script-terminal-with-terminit/) and a lot of that code was adapted from [Scripting the Terminal in Leopard](http://onrails.org/articles/2007/11/28/scripting-the-leopard-terminal).

This was a great start and made terminal automation easy. However, the repository died long ago, and we had continued using the code for a while.
Finally, we decided the time had come to release this code back to the world as a gem. Thanks to ELC for creating the original source for this project.

Also, we didn't take any code from [Project](http://github.com/joshnesbitt/project) by Josh but that project did inspire us to setup terminit
as a gem. Basically, project is a great gem but there were a couple issues with the fact that the terminal doesn't save the session state in some cases.
I had already been using terminit for years so we decided to package this up for easy use.
