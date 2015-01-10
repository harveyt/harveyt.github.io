---
layout: post
title: "Dep"
---

Dep - A Dependency Management Tool
==================================

Background
----------

* Software is often built from [components].
* These components are typically released as new versions.
  * Though in development a component may rapidly change on one or more development branches.
* These components are each typically stored in a seperate source code repository.
* The repository is typically [Git], [Mercurial], [Subversion], [Perforce] or some
  other source code control system.
* Each component might be stored in seperate places in different source code control systems.
* Handling the relationship between all these components is usually a
  manual, error prone, tedious, confusing ad-hoc system.

Purpose
-------

*Dep* automates retrieving the right dependencies at the right version
in a **predictable**, **portable**, **automatable** and **sensible** fashion:

* **Predictible** - The specific version of a dependency used is
  specified exactly as a source code repository commit revision or
  identifier. This is immutable and reproducible (assuming the source
  code repository and system guarantee this).
* **Predictible** - The list of all direct dependencies, names,
  locations and revisions are specified in the file `.depconfig` at
  the root of the component. The `.depconfig` file should be stored
  and version controlled using component's source code control system.
* **Portable** - *dep* is written in [Python] and should run
  on any system that runs [Python]. Examples include; Linux, Mac OS X, and Windows.
  The same commands should be used on all systems to produce the same results.
* **Automatable** - The *dep* program is command-line only; it can be
  used manually from the command line, but often it will be called
  from Makefiles, build scripts and/or by continous integration
  systems.
* **Sensible** - *dep* correctly handles component dependency chains
  as a *Directed Acyclic Graph* (or DAG):
  * *Trees allowed* - A component can itself depend on further components; the component
	will have it's own `.depconfig` which describes it's dependencies.
  * *Shared dependencies allowed* - The same component can be used as a
	dependency more than once; for example *A* depends on *B* depends on *D*,
	and *A* depends on *C* which depends on *D*, here *D* is required twice.
  * *Recursion disallowed* - Component dependency cycles are not
	allowed. For example *A* depending on *B*, where *B* depends on *A* 
	is not allowed, either directly or indirectly. Good software
	developers learn to invert their dependencies using interfaces or
	similar techniques (See [Dependency Inversion Principle]).
  * *Version mismatches disallowed* - If a dependency is used twice,
    it has to be at exactly the same revision. In the previous example
    *D* must be at the same revision. The software engineer must
    manually resolve and fix version mismatches before `dep record`
    can succeed, and thus the dependency tree can never have version
    mismatches.
* **Sensible** - *dep* does one thing only; manage dependencies. This follows
  the *Unix* philosophy of small simple programs working together to build complex workflows.
* **Sensible** - *dep* leverages source code revision systems to get
  dependencies, stores state in one local file `.depconfig` and
  assumes that once you are happy you commit changes to that file to
  make it reproducible.
* **Sensible** - *dep* tries to be simple, but allows complexity if required.
* **Sensible** - *dep* tries not to suprise you; by doing the most sensible thing by default
  and telling you what it did just to make sure.
* **Sensible** - *dep* flattens the DAG of all dependencies to the
  unique set, stored typically in the top project's `dep`
  directory. All sub-dependencies use *symbolic links* back to these
  as required.

Supported Source Code Revision Systems
--------------------------------------

Currently:

* [Git]

Proposed:

* [Mercurial]
* [Subversion]
* [Perforce]

By Example
----------

Let's show how to use *dep* with an example. Here we will use [Git] as
a source code revision system, but it's possible to mix [Git],
[Mercurial], [Subversion], [Perforce] or any other supported system in
any way; each dependency can be in a different source code revision
system.

Our "project" will have a "main" component, which depends on a "helper" component.

### Initialise

Initialise the use of *dep* style dependencies in a "main" component:

```console
$ cd .../project/main
$ dep init
Wrote ".../project/main/.depconfig"
```

This will create a default `.depconfig` in the current directory such
that dependent components can be added.

A dependent component need not have a `.depconfig` file, in which case
it is a "leaf" component (it is assumed that it does not depend on
anything else, unless that is completely automated by the component
itself).

The `.depconfig` should be registered and committed to the "main" component source repository, in this example using [Git]:

```console
$ git add .depconfig
$ git commit -m "Added dependency information."
```

### Add A Dependency

Add a *dep* managed dependency on a "helper" component stored in [Git]:

```console
$ dep add http://example.com/cool-components/helper.git
Added "helper" as dependency of "main":
  Path:	  .../project/main/dep/helper
  URL:	  http://example.com/cool-components/helper.git
  VCS:    git
  Branch: master
  Tag:
  Commit: e742a80412d5c631031c9744963bf8f570e17d77
Wrote ".../project/main/.depconfig"
```

By default the dependency source code system and name is determined
from the URL.

By default the dependency is downloaded from the source code system at
the latest revision on the default branch, and stored under the `dep`
directory in a sub-directory of the same name as the component, in
this example `dep/helper`.

The dependency is added to the `.depconfig` file at this particular
revision and should be committed to "main" source repository, in this
example using [Git]:

```console
$ git add .depconfig
$ git commit -m "Updated dependency information."
```

### Changing Dependency Version

Changing the revision or version of "component" is typically a four step process:

* Use the component's source code revision system to change
  state. This could be checking out a different revision, or it could
  be making local changes and commiting these.
* Build and test everything still works!
* Use `dep record` once complete to record all dependencies state on the main project.
* Commit using the "main" project source code revision system.

In this example we'll change to a specific tagged version using [Git]:

```console
$ cd .../project/main/dep/helper
$ git checkout v1.0.0
$ cd ../..
$ make build test
...
$ dep record
Recorded "helper" dependency of "main":
  Path:	  .../project/main/dep/helper
  URL:	  http://example.com/cool-components/helper.git
  SCM:    git
  Branch: master
  Tag:	  v1.0.0
  Commit: 735d47dba4388582eb1c9df645ba62873698a81d
Wrote ".../project/main/.depconfig"
$ git add .depconfig
$ git commit -m 'Changed helper to v1.0.0'
```

### Ensure Dependencies Are Present

When the primary component is first cloned, sync'd or retrieved from
it's source code revision system, the dependencies will not be
present. To ensure they are present and correct:

```console
$ cd .../project
$ git clone http://example.com/cool-components/main.git
$ cd main
$ dep refresh
Refresh "helper" dependency of "main":
  Path:	  .../project/main/dep/helper
  URL:	  http://example.com/cool-components/helper.git
  SCM:    git
  Branch: master
  Tag:	  v1.0.0
  Commit: 735d47dba4388582eb1c9df645ba62873698a81d
Wrote ".../project/main/.depconfig"
```

Further Reading
---------------

* Use `dep help`, `dep --help`, `dep -h` to get help!
* Use `dep help command`, `dep command --help`, `dep command -h` to
  get a specific help on a given command.

Contributing
============

TBD

License
=======

TBD

[components]: http://www.FIXME.com/
[git]: http://www.FIXME.com/
[mercurial]: http://www.FIXME.com/
[subversion]: http://www.FIXME.com/
[perforce]: http://www.perforce.com/
[python]: http://www.FIXME.com/
[dependency inversion principle]: http://www.FIXME.com/

