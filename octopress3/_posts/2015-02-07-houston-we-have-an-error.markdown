---
layout: post
title: "Houston We Have An Error"
date: 2015-02-07T15:14:19-08:00
comments: true
---

Handling Program Errors (Part 1 of 2)
=====================================

Handling errors in programs is usually boring and tedious, but for
most non-trivial programs it's pretty important:

* Users want a program that does not crash unexpectedly.
* Users want the program to be resilient to their input and typos.
* Programmers want feedback to help them diagnose bugs.

There are many categories of errors:

* Problem with some operating system resource; out of memory, no more
  disk space, network disconnected, paper jammed in printer, neutrino
  hit memory bit.
* Problem with programming logic; code assertion, division by zero, null deference.
* Problem with input (typed, network, file); missing file, typo in input, packet lost.
* Problem from a lower level program function or component; typically a knock on error caused by the above or an even lower functional error.
* ...

Styles Of Error Handling
========================

As there are many sorts of errors, there are also many ways to handle them.

Ignore It
---------

The simplest is to just ignore the problem and pretend it didn't
happen; perhaps everything will be okay anyway, or perhaps the problem
is small enough to be a non-issue, or perhaps the user will just try
again.

This really isn't a solution unless it's a trivial program, or some
kind of trivial issue. However suprisingly we probably use this all the time.

Take this famous trivial C program:

```C
#include <stdio.h>

int main(int argc, char *argv[])
{
    printf("Hello World!\n");
    return 0;
}
```

Lets ask ourselves the great engineering question: "What could possibly go wrong?" Let's see:

* The operating system does not have enough memory or processes to execute the program.
  * Not much we can do about that, lets assume the user will buy more
    memory or kill some other useless programs and try again.
* What if the user has redirected stdout to a file?
* What if that file is on disk that is full?
* What if the program is executing without a terminal?

Generally we tend to assume that simple output to the console works in
our code. We don't care if it doesn't, that situation is so rare it's
not worth bothering about.

One problem (apart from unused arguments) with the code above is that
we've not really been explicit about ignoring the errors from printf().
Somebody looking at our code doesn't know if we knowingly made the
"Ignore It" decision.

Back when I first started learning C in 1988, my good friend Mike
Taylor pointed out two things:

* The `printf()` function returns an `int`. The `printf(3)` manual states that:

  > These functions return the number of characters printed ... or a
    negative value if an output error occurs.

* You should explicitly state you are ignoring function returns by using a `(void)` cast.
  * If you used `lint` or `splint` like program checkers they could
    report this problem, but it's so common that most checkers turn
    this off by default. For example `gcc -Wunused-result` requires
    that the function has a `warn_unused_result` attribute added to report the problem.

So if we were being explicit our program should really read:

```C
#include <stdio.h>

int main(int argc, char *argv[])
{
    (void)printf("Hello World!\n");
    return 0;
}
```

Terminate The Program
---------------------

Another solution would be to terminate the program for a particular
error. This is more suitable for very rare, unrecoverable errors or
disasters. It also has it's use for situations where proceeding is
impossible, doesn't make sense or might be dangerous.

Examples:

* Operating System kernel panics.
* Command line program was passed unknown or bad arguments; the user
  should fix the arguments and try again (or fix the script that is calling the command).
* Application ran out of memory.
  * Really the application should probably save your work first, if it can.

Back to our trivial example:

```C
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    if (printf("Hello World!\n") < 0)
    {
        (void)fprintf(stderr, "Error: could not greet world!\n");
        exit(1);
    }
    return 0;
}
```

On line 6 we check for an error from `printf()`, signalled by a negative number, and if one occurs we handle it as follows:

* On line 8 we inform the user that a problem occured.
  * Interestingly we explicitly ignore the error from fprintf(); if we
    can't write the error text to stderr then things must be really
    hosed (perhaps they redirected stderr to the same full disk).
  * If this error message was important, instead of ignoring we could
    use a logging system like `syslog(3)`, show a GUI pop-up, or some
    other more reliable way of logging the error. In this case, it's
    not worth it.
* On line 9 we exit the program, with a non-zero exit which on Unix-like
  systems means "There was a problem, the program did not run succesfully".

Terminate The Thread or Actor
-----------------------------

Most programming languages have support for [Thread] or [Actor] based
models for concurrent execution of programs. Instead of terminating
the entire program, we could terminate the thread instead and
hopefully signal the parent thread or another actor to notice and
handle the situation.

This is more suitable for resilient systems or services such as web
servers, or perhaps applications that need to save user's work such as
document editors.

Lets take our simple example, and use [Posix Threads] to change our
program to output hello world, and retry every 10 seconds if that
fails until it works:

```C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

void *Okay = (void *)0;
void *Error = (void *)1;

void *print_message_thread(void *arg)
{
    if (printf("Hello World!\n") < 0)
        pthread_exit(Error);
    return Okay;
}

int main(int argc, char *argv[])
{
    void *status = Okay;

    do
    {
        pthread_t thread;
        int rc = pthread_create(&thread, NULL, print_message_thread, NULL);
        if (rc)
        {
            (void)fprintf(stderr, "Error: cannot create thread\n");
            exit(1);
        }

        rc = pthread_join(thread, &status);
        if (rc)
        {
            (void)fprintf(stderr, "Error: cannot join thread\n");
            exit(1);
        }
        if (status == Error)
        {
            (void)fprintf(stderr, "Error: message did not get written\n");
            (void)sleep(10);
        }
    } while (status == Error);

    return 0;
}
```

The complexity here would really only be worth it for resilient
systems, this is total overkill for our simple program!

Things to note are:

* The `pthread_create()` and `pthread_join()` calls can also generate
  errors, oh dear. We made the choice to exit the program in this
  case. This error handling is getting ridiculous!
* The main thread decides what to do about the problem, in this case
  it retries after ten seconds. For a document editor the main thread
  might try to save the document as safely as possible and/or write a
  crash dump or core image for diagnostics.
* The terminated thread could respond to the main thread with more
  information about the error, perhaps an error message and/or
  suggestions on how the main thread should handle the problem; save
  all work, terminate, try again, etc.

Return The Error To The Calling Function
----------------------------------------

We have already seen functions that signal errors by returning an error state:

* `printf()` returns a negative number on error (other values are how much was written).
* `pthread_create()` and `pthread_join` return a non-zero number on error, or zero on success.

This technique is pretty much the standard way of dealing with errors;
defer the problem to somebody else - in this case the caller of the
function. The caller will hopefully deal with the problem; ignore it,
terminate the program or thread, handle it, pass it on, etc.

The `printf()` function highlights a couple of interesting problems:

* How the return value will describe the sort of error that occurred.
* What to do if the return value is used for both normal and error return values.
  * The fancy name for this is the [Semipredicate Problem]; probably
    because the result value is "semi" (or half) result and half "predicate"
    (status, boolean, have we succeeded or not).

In the case of `printf()`, the return value is some negative integer
on error. The C library (and Unix-like operating system) chooses to
provide more information about the error through a global (or thread
local) integer variable `errno`:

* This variable records any errors from any system call and for some C library functions.
* It has well defined values such as `ENOMEM` (out of memory).
* Provides routines like `strerror(errno)` to convert the error index
  into a human readable string for error messages.

A more suitable return value might be an error string or even `Error`
class that describes the problem, however we then run into the
[Semipredicate Problem]; `printf()` wants to return either the number
of bytes written (an `int`) or an error. The designers of the C
library choose to use `int` for simplicitly.

Interestingly this design decision is highlighted more by the `int
fgetc(stream)` function. This reads one character from a given input
stream and returns it. However `fgetc()` needs to signal two other
possibilities; there are no more characters (end of file), or there
was an error reading.

The [Semipredicate Problem] for `fgetc()` is solved by:

* Returning `int`: the character value is converted to an integer (due
  to historical C reasons mostly).
* A value of `EOF` means either end of file or an error occurred. This
  is not a valid character value.
* To determine if there is an end of file or error condition the caller uses:
  * `int feof(stream)` returns non-zero if the stream is at the end of file.
  * `int ferror(stream)` returns non-zero if the stream has an error condition.
* To additionally diagnose on error the actual sort of error use
  `errno` and `strerror()` as described previously.

Returning an error value is very simple to use, but the
[Semipredicate Problem] causes all sorts of issues:

* What value to use from the set of return values to signal an error.
* What if the calling function uses the error return value assuming it's a valid value.
* What if the error value also needs to be a valid return value (or
  there is no appropriate error value in the set to use).

The most famous example of error returns is probably the "null" pointer or reference, which
[Tony Hoare] called "[His] billion-dollar mistake". 

Functions which want to singal an error might return "null", but
typically using this value causes "null pointer exceptions", possibly
cause instant program terminating or at least non-local error handling
or exception handlers. Painful and probably very familiar to the reader:

```C
Document * CreateDocument()
{
    return (Document *)malloc(sizeof(Document));
}
```

The above program has either forgotten that `malloc()` returns a null pointer if it cannot allocate memory, or it's hoping that the caller understands that the pointer can be null and will take appropriate action. Lets see:

```C
void OpenDocument(const char *path)
{
    Stream *s = Stream::Open(path, "r");
    Document *doc = CreateDocument();
    doc->Title = s->ReadLine();
    ...
}
```

Oh dear, looks like line 5 has dereferenced the return value from
`CreateDocument()` without checking for null. This code will crash
badly in low memory situations (but that's so rare, who cares right?).

The problem with "null" is that to solve the [Semipredicate Problem]
we have introduced a value into the set of valid values for Document
pointers, which is not valid. Essentially Document pointers can be
both valid or invalid, but we often forget and treat them as always valid.

What's even more fun is that if we correctly handle the null pointer
in `CreateDocument()` and never return null, we cannot tell externally
and safely use all the values without error checking. Look at line 3,
can we tell if `Stream::Open()` returns null (in which case we have a
null dereference of `s` on line 5), or does it handle all errors
somehow and not return null? Oh dear.

The compiler or other static analysis programs *might* be able to
determine these mistakes, but it would be nice if we could explicitly
state that "CreateDocument can return a valid Document or a null
pointer (or error)". That way the caller would be forced to handle
both situations, or the compiler would fail to compile the code if it
did not.

Again, being explicit about error handling seems to be
important. Hiding or ignoring it is asking for trouble.

On Error Return An Special Object On Which All Actions Do Nothing
-----------------------------------------------------------------

The [Null Object Pattern] works by returning a special return value in
error scenarios which produces no useful or harmful action when
that value is used.

This has limited use, often because the set of actions could be too
large or complex to implement specifically.

However this is easier to achieve using Object Oriented languages. You
would sub-class the valid return class with a special Null variant
that overloads all the base methods to do no work. Even so this has
restrictions; all the methods need to be overloadable, all the methods
should have a "no work" equivalent, the return values for each method
may be tricky to construct or define, and there might be a huge amount
of methods and functionality to replicate.

This case is useful on occasion and is worth mentioning.

Store The Error Globally And Use Auxillary Functions To Check For Errors
------------------------------------------------------------------------

The `printf()`, `fgetc()` functions mentioned previously do return a
value signalling that an error has occurred, but they also use global
data and auxillary functions to describe the error.

The `fread()` and `fwrite()` functions from the C standard library go
the next step and never return errors directly:

> If an error occurs, or the end-of-file is reached, the return value is a short object count (or zero).

These handle errors and side-step the [Semipredicate Problem] by:

* Returning a normal looking value.
  * `fread()` and `fwrite()` return how much was succesfully read/written before the problem.
* Store an error condition and/or description in some global (or thread local) data, and/or
  use functions to determine if an error condition has occurred.
  * In this case `ferror(stream)` should be called to determine if there's an error
  * The `errno` global variable and `strerror(errno)` describes the error further.

Unfortunately this solution is quite error prone, it would be very
easy to forget to call the error checking functions after calling the
functions. A human reader or compiler will have little knowledge to
know that function `XXXX` might cause an error, and that function
`YYYY` should be called to check if one has occurred. The human and
compiler would have to be taught or know this through some other
means.

Raise A Signal / Call An Error Handler Function
-----------------------------------------------

If a function detects an error, instead of terminating the program or
thread or returning some error value it could instead call another
function that will handle the error. 

Essentially we could delegate the problem to another function (or
class or error manager module) that knows what to do; it would of
course have to choose the right technique to resolve the error.

For example the error handler could write an error message, log the
crash, and then terminate the program. If the handler detected a
resource problem it might be able to resolve that; free memory or disk
space. For a transient error it might be able to wait or retry the
operation.

The error handler could be itself parameterized, modularized and
controllable. The application could install special error handlers to
save the users work before termination for example.

Some error handler functions are caused by asynchronous errors; on
Unix and other similar operating systems you can interrupt or abort a
program externally (kill it, interrupt it with Control-C on the
keyboard, "Force Quit" from the menu). These signals are usually
implemented as a slightly more complex asynchronous function calls,
and usually a little more complex due to the asynchronous nature of
the function calls (they can happen at any point in the code).

Throw An Exception / Non-Local Goto
-----------------------------------

A very popular, but somewhat controversial, method to handle errors is
to "Throw An Exception". This is essentially a non-local jump up zero
or more function calls to a higher level piece of code that will
handle the error.

This makes sense; the caller should handle the problem, but typically
the caller does not really need to handle and should just pass on the
error to a function higher up which will handle the problem.

However Google "Exception" "Bad" "Harmful" and you can find opinions
such as [Exception Handling Considered Harmful],
[Exceptions Considered Harmful] or [Why Is Exception Handling Bad].

The problem is that exceptions jumps through code, unwinds the
function call stack and arrives somewhere higher up the call chain
usually without the intermediate functions knowing. This has lots of
technical and philosophical issues:

* Function stack unwinding is often complex and non-portable.
* Function stack unwinding might require extra data and/or be costly.
  * Throwing an exception might be expensive, but not throwing should be zero-cost however.
* What about functions that are skipped over?
* What about the work they did?
* What about objects that were allocated?
* Do we deallocate them automatically?
* Do the callers have to register allocated objects/resources specially to be deallocated.
* Do the callers have to intercept exceptions to achieve this, essentially just making this a weird sort of side-band function return.
* Should the compiler check that the user has checked or passed on all the exception correctly?
* etc.

One big problem is when you read other people's code using exceptions,
there is no explicit mention that errors are being handled or that
exceptions are passing through the code. You therefore cannot
immediately tell if errors are being correctly handled. This leads to
all sorts of invalid assumptions, missed error handling, bugs,
etc. This can also happen when you are writing or rewriting code that
uses exceptions.

Look at this code:

```C++
void WriteDocument(const Document &doc, Stream &output)
{
    WriteDocumentHeader(doc, output);
    for (auto &section : document)
        section.Write(output);
    WriteDocumentFooter(doc, output);
}
```

Can you see the error handling? No. Well, sure it's nice and clean and
simple to read, but there does not seem to be any error handling at
all. Lets guess that the author is diligent and check to see if each
of these functions does error handling. Starting with the first call:

```C++
void WriteDocumentHeader(const Document &doc, Stream &output)
{
    output.Write("<Document>\n");
}
```

Hmmm, lets hope that `Stream::Write()` handles errors. Best look in there:

```C++
void Stream::Write(const char *str)
{
    if (fputs(m_stream, str) < 0)
        throw IOException(m_stream, strerror(errno));
}
```

Ah! Yes, `Stream::Write()` seems to be handling the low level error by
raising an exception. Lets check the other 32 functions just to make
sure `WriteDocument()` uses exceptions correctly. Actually my boss
just asked me when I'll be done, lets hope the author was
dilligent. Hmmm, okay, I didn't remember all the exceptions that were
raised, lets just be cautious and catch everything and hope for the best:

```C++
bool SaveDocument(const Document &doc, const char *path)
{
    try
    {
        Stream *output = Stream::Open(path, "w");
        WriteDocument(doc, output);
        output->Close();
    }
    catch (...)
    {
        return false;
    }
    return true;
}
```

Oh dear so many problems; assumptions that `Stream::Open()` succeeds or
throws an exception (does not return null), if `WriteDocument()` fails,
will the open stream be deallocated? Is path a valid non-null pointer?
Catching everything but then returning false, how will the user know
what went wrong? I'm sure there's more problems here, but this is a
pretty typical result of a coding session.

Done well, exceptions seem like a good solution. Unfortunately there
be many dragons, death and destruction and only valiant and very
dilligent software knights will succeed. I have yet to meet one (or
become one) however. Unfortunately what's worse is we all work with
people (and are ourselves) not always dilligent.

Solving The Error And Semipredicate Problems!?
==============================================

Oh dear. There has to be a better way? What we really need is an
explicit, easy to understand, easy to write way to deal with
errors. Next week we'll look at some new interesting programming
languages and constructs that might help us solve this problem and
move on to something more interesting than error handling.

[Houston We Have An Error Part 2]({% post_url 2015-02-16-houston-we-have-an-error-part-2 %})

[thread]: http://en.wikipedia.org/wiki/Thread_(computing)
[actor]: http://en.wikipedia.org/wiki/Actor_model
[posix threads]: http://en.wikipedia.org/wiki/POSIX_Threads
[null object pattern]: http://en.wikipedia.org/wiki/Null_Object_pattern
[semipredicate problem]: http://en.wikipedia.org/wiki/Semipredicate_problem
[tony hoare]: http://en.wikipedia.org/wiki/Tony_Hoare
[exception handling considered harmful]: http://www.lighterra.com/papers/exceptionsharmful/
[exceptions considered harmful]: http://www.joelonsoftware.com/items/2003/10/13.html
[why is exception handling bad]: http://stackoverflow.com/questions/1736146/why-is-exception-handling-bad
