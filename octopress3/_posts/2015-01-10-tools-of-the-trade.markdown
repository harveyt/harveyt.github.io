---
layout: post
title: "Tools of the Trade"
date: 2015-01-10T16:46:29-08:00
comments: true
---

Summary
=======

A software craftsman needs good tools. This is a list of some of the
tools I use for personal development. Every craftsman must choose the tools
that they are comfortable with. You might find something here useful, you
may well have better alternatives.

Hardware
========

At home I have a very old 2008 iMac, which is mostly for
non-development/home usage. There is also a more recent PC, built from
components in 2013, which runs Windows and is mostly used for playing
games, though one day it may well also build/test Windows builds of
software and/or run various web services.

However, most of my work is done on a laptop. This way I can sit at
the desk at home and connect to an external monitor, or sit on the
sofa, or at the dinner table by the view, or in the coffee shop, or
library, or show my work to somebody while on the bus...

My primary concern was portability, but does that mean you
sacrifice power? Well, you can get close, but it does cost a lot
more. One down side is you don't get as much physical screen size, but
if that's useful connect one or two external monitors.

My other motivations for the particular choice I made were:

* Had and was prepared to spend/invest a chunk of money.
* It will be running a Unix-like operating system; though I have used
  Windows for the past 10 years, I've been using Unix for 35 years.
* Should have sufficient memory to run tools, compilers and several
  web based applications locally. Felt like 16Gb would be sufficient
  for some time.
* Should have a pretty large SSD; faster, lighter, no moving
  parts. Felt like 512Gb would be sufficient for some time.
* Should have a really good 15 inch screen; bright, clear, high
  resolution. I'll be staring at this a lot.
* Should have a decent CPU; four cores perhaps?
* Should have a reasonable GPU; I'm not playing games or doing video
  production, but hey, who knows.
* Should "just work" out of the box, but be easily
  configured/administrated by command line as required.
* Should be light and yet sturdy.

Laptop
------

So, my final choice back in late 2013 was to buy another Apple [MacBook Pro].

A long time ago (back in the 1990's and 2000's) I'd used Dell or
IBM/Lenovo laptops and these were great. Back in 2007 my (then four
years old) laptop's screen died, and I wondered what all the fuss was
about Apple products. Went to their local (then much quieter) Apple
Store and tried their laptops out.

I was instantly impressed; easy to use, well built, nice user
interface, but there's the Unix Terminal under the hood. Nerdy meets
Pretty and has little happy baby laptops.

Since then our household has bought far too many Apple products;
MacBook Pro (2007), iPod Touch, iMac, Time Machine, iPad, MacBook Air,
etc. Possible Apple Fanboy? Perhaps, but I build my own PC's and
use/run Windows for work too. Pragmatic Apply Fanboy then? If Apple
products start declining I'll head for whatever else works for me.

Current Laptop specifications:

* MacBook Pro (Retina, 15-inch, Late 2013)
* Processor: 2.3 Ghz Intel Core i7 (4 Cores, 8 Threads)
* Memory: 16GB 1600 Mhz DDR3
* Graphics: NVIDIA GeForce 750M 2048Mb
* Storage: 500GB SSD

Back then it cost somewhere around $2800 Canadian Dollars including
tax. Current models are very similar in early 2015: see [MacBook Pro]

Backup Drives
-------------

I have a really old 2008 Time Machine, which has 500Gb hard
drive. Everything except the laptop just uses Time Machine for backups
currently. Turn it on, done.

For the laptop I bought a 500Gb mini hard drive, which runs over
USB 3.0. Fast enough for backup purposes. I'll be using this to create
a bootable clone of the laptop about once a week. Soon I'll probably
switch to using something like Crash Plan to incrementally back up all
my machines to local drives and the cloud. That's something for
another week though.

The particular model I choose was a Toshiba 500Gb [Canvio Slim
II]. It's the super light, the size of a wallet, and shiny silver
though not the same as a Mac. I got mine on offer at London Drugs
(Canadian store) for about $80 Canadian dollars, which is ridiculously
cheap in my mind. It's not an SSD, but who cares for backup.

Other Hardware
--------------

* An old faithful [Linksys WRT54GL] Wireless Router running the Linux based custom
  [Tomato] firmware. This thing hasn't gone wrong or needed touching for years.
* A Samsung [S24A850] 1920x1200 24" external monitor. The particular
  one I purchased had DVI, so I had to find a DVI to display port
  cable.

  I've used Samsung monitors at work for ten years, and they seem like
  great monitors. This particular one broke down after two years; the screen went
  pixelated and garbled, like something had chewed on an important signal wire. 

  Samsung has an *excellent* 3 year warranty, you print off the forms
  from their website, put it back in it's original box (keep your
  original boxes always) and put on the pre-paid postage, drop off at
  UPS and UPS send it back. Took under a week to fix, superb service!

Installation and Administration
===============================

Here are some recommendations for installation and administration that
I've always found super handy:

Root Log
--------

I recommend keeping what I call a "Root Log"; a
description of everything I install and configure on each machine.

I've been doing this for years, and call it a "Root Log" because
originally it was a log of all the actions I performed as the "root"
super-user on Unix machines.  On Mac OS X however you can usually do
most of your installation and configuration as a normal user; though
occasionally it will ask for admin/root priviledges via GUI or need a
"su" or "sudo" command.

The log file is stored in the Documents folder, but early on during
installation I symlink Documents into my Dropbox folder:

```console
$ mv ~/Documents ~/Local-Documents
$ ln -s ~/Dropbox/Documents ~/Documents
```

This means all my documents are synchronized to all machines (iMac,
Su's MacBook Air, the Windows PC) and are in the cloud, as well as
being backed up to the TimeMachine (a few times, but who cares).

Provisioning?
-------------

Some people "provision" their laptops; essentially writing scripts
which automate the set-up. Those people are probably already used to
doing this with Chef, Ansible, Puppet or similar software.

I've found that I rarely need to re-install or reproduce my exact
setup, so this "provisioning" idea is overkill for a personal
laptop. Totally would make sense if you need a reproducible
development and production environment across lots of machines.

For me a "Root Log" and good backups are sufficient - when I get new
hardware it's probably time to use newer or updated tools and
installation methods anyway.

Use The Command-Line
--------------------

Sorry, but I just can't understand software developers who rarely use
the command line. I've seen this more in places where Windows is used;
much less so when Linux or Unix is used.

Software developers write code, text, in editors. They make complex
technology using highly complex programming languages, and then some
of them just use a mouse and GUI to install/configure/administrate
their machines? Even worse, they also don't *bother* to try to automate
tasks that they perform, rather use a GUI and manually click things
all day?

For goodness sake **LEARN TO USE A DECENT SHELL AND SCRIPTING LANGUAGE**.

I've been using Unix for so long it's second nature. With Mac OS X you
get [bash], [python], [ruby] and [perl] all installed by default so there's no
excuse.

On Linux it's similar, and on Windows install [Cygwin].

I mainly use [Bash] scripts for automation, though I'm beginning to
use [Python] (previously I "suffered" with [Perl]) and might
try out [Ruby] for comparison.

Software
========

Many of my choices reflect the choice of [MacBook Pro] as my primary
development machine. My list of software in order of installation is
described below:

Operating System - Mac OS X
---------------------------

[MacBook Pro] comes pre-installed with Mac OS X, I'm now running
Yosemite 10.10.1. The main thing for me is:

* It's easy to use initially; just open your new laptop and answer a
  few questions and your done. No installing, all done.

* It's not annoying. Sorry I find Windows far too annoying. Linux is
  annoying because you have to spend a long time fiddling with things,
  which was fun back in the 1990's when I was developing Unix
  operating systems, but these days I want my basic laptop to "just
  work please", but still have the ability to be configured, scripted
  and tweaked like Unix.

  Yes, I'd use Linux and have done often. Yes I'd use Windows, and
  have done often, though I always install [Cygwin] to give me Unix
  like command line.

Office Tools - iWorks
---------------------

I use Apple's free Pages, Numbers and Keynote. I have used Microsoft
Office, but it's way more annoying. Can't beat free; in which case the
alternative might be Open Office or Libre Office.

These are installed in the App Store and can't (yet) be automated, but whatever.

XCode
-----

I also install XCode from the App Store, just in case I feel the need
to use it (I rarely do). I do most of my development with other tools
so I can be more platform agnostic.

Software Management - Homebrew
------------------------------

Installing software can be done a few different ways; go to website
and download it manually and install, download the source and build it
yourself, provisioning using things like Chef, download from the App
Store, etc.

On Mac OS X I've found using [Homebrew] does almost all I need in one
simple consistent command line driven package.

First things I install from the command line is:

* [Homebrew] - which often build/installs from source, but often gets pre-built binaries.
* [Homebrew Cask] - partner in crime which is used to auto-install third-party applications.

Check the [Homebrew] home page for the current install magic command, as of Jan 10th 2015 the shell magic copy-paste was:

```console
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Check the [Homebrew Cask] home page for the current install magic command, as of Jan 10th 2015 the shell magic copy-paste was:

```console
$ brew install caskroom/cask/brew-cask
```

Pretty much after this you install source/pre-built binaries like this:

```console
$ brew install THING
```

Applications (Casks) like this:

```console
$ brew cask install THING
```

You can find things to install like this:

```console
$ brew search SOMETHING
```

Look at [Homebrew] and [Homebrew Cask] for more information. From now
on I'll include the short `brew` command for software I use.

Verson Control System - Git
---------------------------

```console
$ brew install git
```

I use [Git] where possible to store and version source code. It's a
popular distributed version control system, which means you can much
more easily share work and contribute to open source projects.

If you have no idea what this is, where have you been? Under a rock?
Seriously, read up on these things **RIGHT** **NOW**.

I've used SCCS, RCS, CVS, Subversion, and Perforce. But for me [Git]
is preferable (partly due to it's popularity perhaps).

I store my repositories in the cloud; private [Git] repository on
[Bitbucket] (free unlimited private repositories for one to five
people), and public repositories on [GitHub] (free for unlimited
public repositories for open source development).

Standard Tool Configuration
---------------------------

```console
$ git clone XXX/config.git $HOME
```

Next thing I install is my own tool configuration scripts and
files. Most of the files are for configuration of [Bash], [Emacs] (the
editor I use, see below), and [Git], but has things like fonts, SSH,
X11, shell and scripts configurations.

All my configuration is stored as a [Git] private repository, which is
remotely hosted on [Bitbucket]. The configuration is
portable to any machine/platform I use frequently; Mac OS X, Windows,
and Linux.

Editor - Emacs
--------------

```console
$ brew install --cocoa emacs 
$ brew linkapps
```

Note: The `--cocoa` and `brew linkapps` give you a native Mac OS X
Cocoa native application, not just the terminal based Emacs.

I use [Emacs] for several reasons:

* *Portability* - it's everywhere; Mac OS X, Windows, Linux, PDP-11,
  Amiga. Pretty much looks and works the same too. My configuration is
  practically identical for Windows, Linux and Mac OS X.
* *Programmability* - you can reconfigure it exactly as you like using
  Lisp. Yeah, Lisp. Oh well, I like Lisp fortunately (or at least I
  did back in 1989 when I first started using Emacs).
* *Free* - It's $0.00 and the source is "open" to modification (GNU Free Software).
* *Familiarity* - I've been using it since 1989. The bindings are burned
  into my subconcious muscle memory. Yes, at first using Emacs hurt,
  but after a week or so I got used to it. Yes, most other editors
  offer an Emacs-like mode, but I've tried this and just end up back
  with Emacs for all the other reasons. Yes, I use `vi` occasionally
  just in case `Emacs` disappears off the face of the earth or
  something weird.
* *Hands On Keyboard* - Mouse/Trackpad? I try to avoid these during
  development; I can type faster and more accurately than I can
  point. Plus typing is easily recorded and automatable with Emacs
  macros, Emacs Lisp, [Bash] shell or [Python] scripts.
* *Buffers/Windows/Frames* - Make new views on the same file, open new
  windows all with quick key presses.
* *Integration* - pretty much anything can be done in Emacs. Write code
  (supports practically any language out there, and if not, just write
  some Lisp), debug code, read email, news, run shells, play games. I
  personally use it for writing code, debugging and running a shell.

  In fact once I've installed emacs, I run shell in an Emacs
  buffer. That way I can quickly copy and yank (paste) text from the
  shell into the Root Log.
* *Minimal GUI* - Emacs pretty much shows you a window with your files' text in it.
* *Well Documented* - Emacs has full documentation; on any Lisp
  function, key binding, command, plus it also lets you read man pages
  and even web pages (if you so wish) in Emacs.
* *Live Programming* - Emacs is actually really a live Lisp-programming environment
  disguised as an editor. You can open a "scratch" buffer and type
  Lisp code at it, while Emacs is running, and modify your running
  Emacs functionality on the fly. Configuration of key bindings, code
  highlighting, everthing can be changed live; and since it's all just
  text code, it can be stored and version in a VCS; in my case the
  [Git] configuration repository I take everywhere.

There are some downsides; it's a tired old beasty, you'll be holding the Control key
down a lot, you might get tired hands or worse, and all those "Lisp brackets" and "neck
beard" jokes from colleagues get a bit tedious.

Documents in the Cloud - Dropbox
--------------------------------

```console
$ brew cask install dropbox
$ mv ~/Documents ~/Local-Documents
$ ln -s ~/Dropbox/Documents ~/Documents
```

Keeps all the Documents in sync across all machines and in the cloud.

See [Dropbox] for more information on signing up and different plans and prices.


Too Many Passwords? - 1Password
-------------------------------

```console
$ brew cask install 1password
```

1Password does what it says on the tin; you only need to remember one
password, it does the rest.

It's a standalone application and also a browser extension; once
you've entered the passphrase for 1Password, you can hit a key binding
to pop-up a search in your browser; type in a website name, and it
takes you there, enters the right user name and password for that site
and logs you in. Magic!

1Password keeps all your passwords in one super secure place, and
since we use [Dropbox] it's synchronized and accesible everywhere
(even on the web). [1Password] supports Mac OS X, Windows, iPhone/iPad
and Android.

I use a [Diceware Passphrase] for my "one password":

* Strong - I use a six word passphrase. The words are generated by
  rolling physical dice, and looking them up from a published source
  list of words. The passphrase strength is in the fact that you roll
  the dice a *lot* (well okay 30 times) to make about 78 bits of entropy.
  
  "Eh? 78 bits of what?"

  That means there's so many possibilities that even knowing the
  source dictionary means it would take a bazillion computers a
  bazillion years to crack (or something, see
  <http://en.wikipedia.org/wiki/Passphrase>):

<div style="margin-left: 2em">
```console
$ echo '6 ^ 30' | bc
221073919720733357899776
```
</div>

* Easy to remember - The words, although completely unrelated, are
  made into a picture/story that is easier to remember. Doubt this?
  Read the excellent [XKCD](http://xkcd.com/936/) comic.

  Initially you have to write it down on paper and type it a few times
  before it really sinks in. Once you have it memorized, tear up the
  paper, seperate them into five piles randomly, burn them, flush the
  pieces down six different toilets (or whatever feels safe to you).

* Only One - you only need remember one pass phrase, forever.

See [1Password] for more information and getting a license. 

Moving Windows - Optimal Layout
-------------------------------

```console
$ brew cask install optimal-layout
```

Handy little utility for using keyboard bindings to move and resize
windows. I prefer to keep my "Hands On Keyboard" and not on the mouse
or track pad.

See <http://most-advantageous.com/optimal-layout/> for cost, etc. Also available in App Store.

Why Is My Laptop Slow? - System Pal
-----------------------------------

A handy menu bar app that shows memory/cpu/temp/disk/net
statistics. Configurable and discrete. Available in the App Store for a small price.

See <https://itunes.apple.com/ca/app/systempal/id453164367?mt=12>

Laptop Auto-Sleep Off - Caffeine
--------------------------------

```console
$ brew cask install caffeine
```

A super simple menu bar app that stops your Mac going to sleep. Handy
for presentations, playing guitar, and whenever you need your Mac to
just do things without you touching it.

See <http://lightheadsw.com/caffeine/>

Git Makes No Sense? - Source Tree
---------------------------------

```console
$ brew cask install sourcetree
```

A **Free** GUI for [Git] and `Mercurial`. Occasionally this is handy
for inspecting source, history, branch state visualization and remote
repository states or for doing things with [Git] that are unfamiliar.

It's free! By those awesome [Atlassian] people.

See <http://www.sourcetreeapp.com>

General Development Tools
-------------------------

```console
$ brew install ctags
$ brew install global
$ brew install idutils
$ brew install ispell
$ brew tape homebrew/dupes
$ brew install gdb
$ brew install imagemagick --with-libtiff
$ brew install pcre
$ brew install wget
```

Various things I use in development, as you can see [Homebrew] means
you just find something useful and install it.

Much of what I use comes by default with Mac OS X and XCode:

* C/C++ Compiler - `clang`
* Build Automation - `make`
* Scripting - `bash`, `python`, `ruby`, `perl`, `awk`, `sed`

Virtual Machines - Virtual Box
------------------------------

```console
$ brew install virtualbox
```

Intall [Virtual Box](https://www.virtualbox.org) so you can play with
Virtual Machines, run Mac OS X/Linux/Windows on the same machine,
whatever. It's *free*!

Java
----

```console
$ brew cask install java
$ brew tap caskroom/versions
$ brew cask install java7
```

Install both [Java](https:///www.java.com/) 1.8 and 1.7 for playing Minecraft, running
Jira/Confluence and other web applications.

RSS Reader - NetNewsWire
------------------------

```console
$ brew cask install netnewswire
```

Subscribe to and view RSS web feeds in style. Reasonably priced (Beta is free right now).

See <http://netnewswireapp.com>

Cloned Bootable Backup - Carbon Copy Cloner
-------------------------------------------

```console
$ brew cask install carbon-copy-cloner
```

I use CCC to make a cloned bootable backup of the laptop to an
external backup drive about once a week. This software is pretty much
"click-click-click", plus it has command line automation in case I
want to get serious later.

See <https://bombich.com>, it's fairly expensive as software goes, but backups!

Webite/Blogging - Jekyll, Octopress, GitHub
-------------------------------------------

See [Setting Up A Free Blog]({% post_url 2014-12-31-setting-up-a-free-blog %})

Drawing Stuff - Omnigraffle
---------------------------

```console
$ brew cask install omnigraffle
```

If you ever need to draw boxes and lines to work out some software
architecture, or draw some "UML" like class relationships to design
something, then Omnigraffle is one good, if slightly expensive way.

See <https://www.omnigroup.com/omnigraffle>

Future Blogs/Ideas
==================

* *Task and Bug Tracking* - Jira
  * Already installed, already using it in a very light weight way for tracking tasks.
* *Internal Wiki* - Confluence
  * Already installed, will use it for internal documents and design.
* *Blog Comments* - Discourse
  * So you notice you can't comment? Well, as of Jan 2015, I've not got that far yet!
  * Read about Discourse, seems free and reasonable.
* *Continuous Integration* - Jenkins? Bamboo? Team City? 
  * Not sure yet, need to evaluate
* *Continuous Quality* - Sonar Qube, oclint
  * Not installed yet, used before, does the job.
* *Continuous Backup* - Crash Plan?
  * Not installed yet, read up on it, need to try it out.

[macbook pro]: https://www.apple.com/ca/macbook-pro/
[canvio slim ii]: http://www.toshiba.com/us/accessories/Portable/500GB/Slim-II/HDTD205XSMDA
[linksys wrt54gl]: http://support.linksys.com/en-ca/support/routers/WRT54Gl
[tomato]: http://www.polarcloud.com/firmware
[s24a850]: http://www.samsung.com/us/support/owners/product/LS24A850DW/ZA
[cygwin]: https://www.cygwin.com
[mingw]: http://www.mingw.org
[mingw-w64]: http://mingw-w64.sourceforge.net
[bash]: http://www.gnu.org/software/bash/
[python]: https://www.python.org
[perl]: https://www.perl.org
[ruby]: https://www.ruby-lang.org/en/
[homebrew]: http://brew.sh
[homebrew cask]: http://caskroom.io
[git]: http://git-scm.com
[bitbucket]: https://bitbucket.org/
[github]: http://github.org/
[emacs]: http://www.gnu.org/software/emacs/
[dropbox]: https://www.dropbox.com/
[1password]: https://agilebits.com/onepassword
[diceware passphrase]: http://world.std.com/~reinhold/diceware.html
[atlassian]: https://www.atlassian.com
