---
layout: post
title: "Fixing Confluence Key Bindings on Mac OS X"
date: 2015-01-17T14:50:45-08:00
tags: confluence macosx emacs
comments: true
---

Problem
=======

The main point of using Confluence is to type wiki pages really
quick. I'm so used to Emacs key bindings that they are at the muscle
memory level of my subconcious. Also I'm a fan of "Hands On Keyboard"
(and not the mouse or track pad) for getting my thoughts down before I
forget them.

The problem is that on Mac OS X, Confluence uses both the Control Key &#x2303; and the
Command Key &#x2318; to do access the same bindings, particularly in the rich text editor.

The basic Emacs editing keys therefore conflict with Confluence functionality as follows:

| Key ____________________ | Expected Meaning ________ | Default Functionality _____________________________ |
| -- | - | - |
|Control-A|Move to beginning of line|Works Fine|
|Control-E|Move to end of line|**BROKEN** Does nothing|
|Control-K|Kill line|**BROKEN** Opens Insert Link Dialog|
|Control-F|Forward character|Works fine|
|Control-B|Backwards character|**BROKEN** Turns on Bold text|
|Control-N|Next line|Works fine|
|Control-P|Previous line|Works fine|

What would be great is if we could fix these issues.

Solution - Fix Confluence Itself
================================

The primary reason things do not work as expected is that Atlassian
has modified TinyMCE, which provides the rich text editor, so that
Confluence accepts both Command and Control for operations in the rich
text editor. Therefore Control-B and Command-B both turn on bold text.

We can undo this change and get most of the way there, however note that:

* These steps worked for Confluence 5.6.5, but other versions should be similar.
* This makes most rich text edtior Confluence commands only use
  Command, not Control; some documentation may say "Control-B turns on
  Bold", be aware that you need to use "Command-B" instead.
* You need access to the Confluence server itself and have some basic shell skills.
  * Alternatively get your local admin to make these changes.
* In the instructions, replace $CONFLUENCE_INSTALL and $EDITOR with your local values.
  * I have these set in my environment.

Step 1: Extract and edit TinyMCE editor
---------------------------------------

```console
$ cd $CONFLUENCE_INSTALL/confluence/WEB-INF/atlassian-bundled-plugins
$ mkdir ext
$ cd ext
$ jar -xf ../atlassian-tinymce-5.6.5.jar
$ $EDITOR scripts/tiny_mce/classes/Editor.js
```

Step 2: Change code to only accept Control Key
----------------------------------------------

Code originally reads:

```javascript
...
		each(t.shortcuts, function(o) {
			//if (tinymce.isMac && o.ctrl != e.metaKey)
			//ATLASSIAN - We allow both the cmd and ctrl modifiers on OSX
			if (tinymce.isMac && (o.ctrl != e.metaKey && o.ctrl != e.ctrlKey))
				return;
			else if (!tinymce.isMac && o.ctrl != e.ctrlKey)
				return;
...
```

Modify this to undo the ATLASSIAN change:

```javascript
...
		each(t.shortcuts, function(o) {
			if (tinymce.isMac && o.ctrl != e.metaKey)
			//ATLASSIAN - We allow both the cmd and ctrl modifiers on OSX
			//if (tinymce.isMac && (o.ctrl != e.metaKey && o.ctrl != e.ctrlKey))
				return;
			else if (!tinymce.isMac && o.ctrl != e.ctrlKey)
				return;
...
```

Step 3: Make same changes to -min file
--------------------------------------

There should also be a minimum text version of the file with a `-min`
suffix. The same change should be made there too:

```console
$ $EDITOR jscripts/tiny_mce/classes/Editor-min.js
```

Before:

```javascript
...
i(C.shortcuts,function(F){if(n.isMac&&(F.ctrl!=t.metaKey&&F.ctrl!=t.ctrlKey)){return}else
...
```

After:

```javascript
...
i(C.shortcuts,function(F){if(n.isMac&&F.ctrl!=t.metaKey){return}else
...
```

Step 4: Save changes back to Jar
--------------------------------

We had to extract the file to edit from a Jar archive, so now we
recreate an updated version (saving the original in case disaster
strikes):

```console
$ cp ../atlassian-tinymce-5.6.5.jar ../atlassian-tinymce-5.6.5.jar.ORIG
$ jar -cf ../atlassian-tinymce-5.6.5.jar
$ cd ..
$ rm -rf ext
```

Step 5: Restart Confluence and Browser
--------------------------------------

For the changes to take affect you will need to stop and restart Confluence, and in my experience the browser also.

Step 6: Fix Control-E using Karabiner
-------------------------------------

Unfortunately Control-E not working seems to be a general bug. I tried
for a while to work out why it doesn't work and gave up. See
<https://jira.atlassian.com/browse/CONF-25894> to check if it has been
fixed, if so, you may already have a working Control-E and can skip
this step.

To fix Control-E, and in fact for general keyboard remapping, I
installed [Karabiner]. This is "A powerful and stable keyboard
customizer for OS X", and so it's useful for other keyboard mappings.

I use [Homebrew] and [Homebrew Cask] so installation can be done on the command line:

```console
$ brew cask install karabiner
$ ln -s /Applications/Karabiner.app/Contents/Library/bin/karabiner /usr/local/bin
```

Alternatively go to [Karabiner] and download and install the application manually.

If you are using Windows, I use and recommend [XKeymacs] which does
something similar; it is useful for ensuring non-Emacs applications on
Windows feel more like Emacs, so it's also generally useful for other
reasons.

For [Karabiner] you can easily remap Control-E (and Control-A) to use
different Mac OS X specific key presses which do work in the rich text
editor in Confluence, thus fixing the bug:

```console
$ karabiner enable option.emacsmode_controlAE
```

Alternatively in GUI do `Emacs -> Control+AE to Command+Left/Right`

Alternative Solutions
=====================

You could just use [Karabiner] and map key the broken bindings
(Control-E, Control-K, Control-B) to something that does work. The
beauty here is that you won't need to fix Confluence.

There may also be other key bindings you simply don't like in
Confluence. These can be changed in source fairly easily using similar
steps to the above. For example, change the Control-1 through
Control-9 (which conflict with Safari's Goto Bookmark) to use
Control-Shift-1 etc:

```console
$ cd $CONFLUENCE_INSTALL/confluence/WEB-INF/atlassian-bundled-plugins
$ mkdir ext
$ cd ext
$ jar -xf ../confluence-keyboard-shortcuts-5.6.5.jar 
$ $EDITOR jscripts/tiny_mce/classes/Editor.js

... Change all "[Ctrl+1]" to "[Ctrl+Shift+1]" for 1..9

$ cp ../confluence-keyboard-shortcuts-5.6.5.jar  ../confluence-keyboard-shortcuts-5.6.5.jar.ORIG
$ jar -cf ../confluence-keyboard-shortcuts-5.6.5.jar *
$ cd ..
$ rm -rf ext
```

* Restart Confluence and your browser.

[karabiner]: https://pqrs.org/osx/karabiner/
[xkeymacs]: http://xkeymacs.sourceforge.jp/
[homebrew]: http://brew.sh
[homebrew cask]: http://caskroom.io
