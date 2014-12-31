---
layout: post
title:  "Setting Up A Free Blog"
date:   2014-12-29 18:30:00
categories: jekyll octopress github blog
---

Purpose Of This Tutorial 
========================

* A basic blog setup:
  * Post first blog entry.
  * Themes, layout and prettiness comes later.
* Close to free as possible:
  * Free as in beer (almost no money).
  * Free as in speech (open source).
* Want lots of control, not afriad of command line tools.
  * Change Management using [git].
  * Blog and web pages are served as static html.
  * Preview and author locally using text files.
  * Publishing is a simple shell command.

Tools Required
==============

This tutorial assumes usage and familiarity with the following tools:

* **[bash]** - Unix shell command line terminal:
  * This tutorial uses Mac OS X Yosemite 10.10, but any Unix-like system will be very similar.
  * Alternatives include:
	* Linux, which should have [bash] installed.
	* Windows, where you might want to install [Cygwin], [MinGW] or [MinGW-w64].
* **Text editor** - needed to configure and write blogs:
  * I personally use [Emacs].
	* Download and install [markdown-mode] and [yaml-mode].
  * Alternatives include [Vim], and so many others.
	* Hopefully your editor of choice supports [Markdown] and [YAML].
* **[git]** - for source code control.
* **[GitHub]** - providies hosting of the web page and git repository.

New Tools Used
==============

### Jekyll and Octopress 3

This tutorial uses [git] and [GitHub] for source code control, and if you
check out [GitHub Pages] you'll see that they "support Jekyll, a
simple, blog-aware static site generator." (from [Using Jekyll with Pages]).

[Jekyll] allows you write your blog and website in [Markdown] (or
other similar markup languages) in text files. With a simple build
command [Jekyll] converts these into static html pages.

Since this tutorial is using [git] to store the blog and website, it
leads to a simple work flow for creating a blog post:

* Create a new post text file.
* Write [Markdown] in that text file with our editor.
* Preview the resulting site locally using [Jekyll].
* Add and commit this file locally using [git].
* Publish the web site by using `git push` to push the local changes to [GitHub].
* [GitHub] will then automatically regenerate the website using [Jekyll] on it's servers.

[Jekyll] itself is written in [Ruby] and is a fairly complex and low
level framework. To make life simple this tutorial will use [Octopress 3]
on top of [Jekyll].

From [Octopress] home page:

> Octopress is a framework designed by Brandon Mathis for Jekyll, the blog aware static site generator powering Github Pages. To start blogging with Jekyll, you have to write your own HTML templates, CSS, Javascripts and set up your configuration. But with Octopress All of that is already taken care of.

**NOTE:** As of December 2014, [Octopress] is at version 2, and version 3 is being actively developed and documented as a release candidate. Hopefully by the time you're reading this it will have been released, well tested and documented.

### Markdown

[Markdown] is a simple plain text based formatting language which is
typically converted into HTML to render on a web page.

By default [Jekyll] and [Octopress 3] use [Markdown] text files to
represent blog posts. Also [GitHub] uses [Markdown] for it's wiki, and
README files, so knowing this will be useful.

For example the following is [Markdown] text:

```
Title
=====

A list of things that are **important**:

* Sandwiches
* Snow
* Books
```

The default [Octopress 3] theme would look like this in a browser:

> <img src="/assets/example-markdown-output.png" alt="Example Output" height="170">

The equivalent generated HTML would be:

```html
<h1 id="title">Title</h1>

<p>A list of things that are <strong>important</strong>:</p>

<ul>
  <li>Sandwiches</li>
  <li>Snow</li>
  <li>Books</li>
</ul>
```

The general idea is that [Markdown] is easier to read and write, but
you can include HTML if you need more control or something specific
that [Markdown] does not provide.

### Ruby

You may or may not be familiar with [Ruby]. For this tutorial you'll
only need to ensure it's installed and install [Ruby Gems] which is
pretty easy. 

Generally it's worth learning [Ruby] so you can go deeper into
[Jekyll], [Octopress 3] and many other useful tools and applications.

### YAML

[YAML] is a data serialization standard. [Jekyll] and [Octopress 3]
use this in some configuration files. It's also used by many other
tools and applications, so it's worth learning too.

Tutorial
========

Check Ruby Is Installed
-----------------------

Typically [Ruby] is installed on most Unix-like operating systems. As mentioned earlier, this
tutorial uses Mac OS X Yosemite 10.10, but you'll likely have something different.

Let's see if [Ruby] is installed already:

```console
$ type -p ruby
/usr/bin/ruby
$ ruby -v
ruby 2.0.0p481 (2014-05-08 revision 45883) [universal.x86_64-darwin14]
```

If you have [Ruby] version 2.0.0 or later you're probably good to go.

As shown above, on Mac OS X the default version of [Ruby] is
`/usr/bin/ruby`. This is the system version and installing Ruby gems
will require you to be super-user or use `sudo`, which is not
advisable.

The best solution is to install a local up-to-date version of [Ruby],
one good way to do this on Mac OS X is to use [Homebrew] package
manager:

```console
$ brew update
$ brew install ruby
...
$ ruby -v
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]
```

Install Jekyll and Octopress 3
------------------------------

Next install [Jekyll] and [Octopress 3]:

```console
$ gem install octopress --pre
Fetching: fast-stemmer-1.0.2.gem (100%)
Building native extensions.  This could take a while...
# lots of similar output for about a minute ...
$ type octopress
octopress is /usr/local/bin/octopress
```

So far so easy. Installing [Octopress 3] automatically installs
[Jekyll] as a dependency. See [Octopress 3] for more details.

**NOTE:** The `--pre` option is required until [Octopress 3] is officially released.

Create Blog Locally
-------------------

Create the bare bones [Octopress] and [Jekyll] directory, which contains the
most basic website and a single example blog post.

For personal [GitHub Pages] the repository on [GitHub] has to be called
`NAME.github.io`, where `NAME` is your account name, so for consistency we
keep the directory and repository name the same. See
[GitHub Pages Help](https://help.github.com/categories/github-pages-basics)
for more help.

**NOTE:** Replace `NAME` with your [GitHub] account name.

```console
$ octopress new NAME.github.io
New jekyll site installed in /Users/NAME/Projects/NAME.github.io. 
Octopress scaffold added to /Users/NAME/Projects/NAME.github.io.
```

Preview Blog Locally
--------------------

The previous step created enough data that [Jekyll] can build and view
the equivalent static HTML site.

The command `jekyll serve` will:

* Build the HTML site.
* Start a simple local web server 
* Allow you to locally preview your site in your browser.
* Rebuild the site if any files are modified, so you can watch changes.

```console
$ jekyll serve &
[X] NNNN
Configuration file: /.../NAME.github.io/_config.yml
            Source: /.../NAME.github.io
       Destination: /.../NAME.github.io/_site
      Generating... 
                    done.
 Auto-regeneration: enabled for '/.../NAME.github.io'
Configuration file: /.../NAME.github.io/_config.yml
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

As the command output shows we can open the local web page. Neat trick
is that on MacOSX the command `open` will do this for us:

```console
$ open http://127.0.0.1:4000/
```

Initialise and Commit To Git Locally
------------------------------------

**NOTE:** Replace `NAME` with your [GitHub] account name.

```console
$ cd NAME.github.io
$ git init
Initialized empty Git repository in /.../NAME.github.io/.git/
$ git add .
$ git commit -m 'Initial commit.'
[master (root-commit) b6f0c3c] Initial commit.
 19 files changed, 820 insertions(+)
 create mode 100644 .gitignore
 # lots of files ...
```

Create our GitHub Personal Page
-------------------------------

**NOTE:** Replace `NAME` with your [GitHub] account name, and `REMOTE` with the name of the remote used to push to. Good examples might be `origin` or `github`. Also note that the remote URL assumes you're using ssh connections to [GitHub].

```console
$ git remote add REMOTE git@github.com:NAME/NAME.github.io.git
$ git push --set-upstream REMOTE master
```

One first pushing to [GitHub], it will take up to 30 minutes to generate your website.

While you wait, you might want to:

* Bookmark `http://NAME.github.io/` in your browser.
* Read more about [Markdown]
* Read more about [Octopress 3]
* Read more about [Jekyll]

Create a Custom Domain
----------------------

Personalize The Default Blog
----------------------------

Improve Code Blocks
-------------------

* Install codefence
* Install solarized
* Add to _config.yml
* Change to light solarized

Write Your First Blog
---------------------

Go Crazy
--------

You might want to do more crazy things later:

* Install more [Jekyll] and [Octopress 3] plugins.
* Add a comment system.
* Find or make your own theme.
* Add a better home page.
* Add other pages, background images, and common headers and footers.

Some of these might be a subject for a future tutorial.

[git]: http://git-scm.com
[bash]: http://www.gnu.org/software/bash/
[cygwin]: https://www.cygwin.com
[mingw]: http://www.mingw.org
[mingw-w64]: http://mingw-w64.sourceforge.net
[emacs]: http://www.gnu.org/software/emacs/
[markdown-mode]: http://jblevins.org/projects/markdown-mode/
[yaml-mode]: https://github.com/yoshiki/yaml-mode
[vim]: http://www.vim.org
[markdown]: http://daringfireball.net/projects/markdown/
[liquid]: http://liquidmarkup.org
[yaml]: http://www.yaml.org
[github]: https://github.com
[github pages]: https://pages.github.com
[using jekyll with pages]: https://help.github.com/articles/using-jekyll-with-pages
[ruby]: https://www.ruby-lang.org/en/
[ruby gems]: http://guides.rubygems.org/what-is-a-gem
[homebrew]: http://brew.sh
[jekyll]: http://jekyllrb.com
[octopress]: http://octopress.org
[octopress 3]: https://github.com/octopress/octopress

