Consular
===========

Consular automates your development workflow setup.

Read the rest of the README and check out the [wiki](https://github.com/achiu/consular/wiki) for more info!

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

## IMPORTANT ##

After that, you'll need to install a 'core' so you can run Consular on
your desired platform.

Cores
-----

Cores allow Consular to operate on a variety of platforms. They abstract the general behavior that consular needs to run the commands. 
Each core inherits from ([Consular::Core](http://github.com/achiu/consular/blob/master/lib/consular/core.rb)) and defines the needed methods.
Some of the cores that are available are:

 * [OSX](http://www.github.com/achiu/consular-osx) - Mac OS X Terminal
 * [iTerm](https://github.com/achiu/consular-iterm) - Mac OS X iTerm
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

#### Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

#### Copyright

Copyright (c) (2011 - when the Singularity occurs) Arthur Chiu. See LICENSE for details.

