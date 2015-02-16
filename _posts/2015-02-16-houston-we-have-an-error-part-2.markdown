---
layout: post
title: "Houston We Have An Error Part 2"
date: 2015-02-16T09:47:03-08:00
comments: true
---

In my previous blog [Houston We Have An Error Part 1]({% post_url 2015-02-07-houston-we-have-an-error %}) we saw the various ways of handling errors.

There are a few new languages that provide systematic ways of handling
errors, this blog post gives a general overview of these ideas.

The Semi-Predicate Problem
==========================

The [Semipredicate Problem] occurs when we have a function that wants
to return both a valid value or failure (or status, predicate) value
that denotes the function did not succeed.

The example from last week was the `printf()` function from the C
language, which returns an `int`. The `printf(3)` manual states that:

  > These functions return the number of characters printed ... or a
    negative value if an output error occurs.

The problem is that the type 'int' is used both for valid values and
success status, although in this case positive values denote success
and negative denotes failure.

Lets imagine another function `int Parse(string)`; a function which
takes some string and returns the integer value of that string. What
should happen if the string is not a valid integer?

Unfortunately the function should parse any valid integer in the range
support by the `int` type, and so there is not a spare value to use
for "error".

Function Based Solutions
========================

Some solutions used in practice essentially add extra arguments,
return values or raise exceptions:

* Complex overloading of return value:
  * `long strtol(const char *str, char **endptr, int base)`
  * The C standard library function converts a string to a `long` (long
    integer) and then has a fairly complex overloading on the return
    value of 0, which is either an error (depending on the global
    `errno` value and value passed through the optional
    `endptr`). Yuck.
* Return through an output argument.
  * `bool TryParse(string s, out int result)` 
  * The C# function returns bool to indicate success, and returns the
    value through the output argument `result`.
* Raise an Exception. 
  * `int Parse(string)`
  * The C# function which returns the integer parsed, or on error raises an exception.
* Return multiple values.
  * `Parse(string) -> (int, bool)`.
    * Here we use the `->` notation to means "returns" and `(x, y)`
      means a tuple type (pair of values). The first return value is
      the actual integer, the second return value is the status.

Type Based Solutions
====================

However lets restate our desire in English again: "Parse takes a
string and returns either an integer or an error." Lets write that a
little more programmatically: `Parse(string) -> int OR error`.

What might really help is a type safe way to represent the type
"X or Y" where X and Y are types. Sounds a bit like C or C++
unions?

Turns out there's actually a few different sorts of [Union]:

* [Untagged Union] as from C and C++.
  * The untagged union type can contain several different types but
    there is no way to tell from the union itself which type is contained in the union.
* [Tagged Union] also known as a Sum Type Union, [Disjoint Union], Either, or Variant.
  * A tag field or sub-typing is used to determine which type is held in the union.
* [Set Theory Union] also confusingly just called a "union" in some
  literature is where the union essentially contains all the possible
  values of both types, and only allows operations that would be valid
  for all these types.
  * See [Programming With Intersection Types] by Benjamin Pierce.
  * See also [Types and Programming Languages] by Benjamin Pierce.

Untagged Union Example
----------------------

First attempt at a string to integer parser in C++ might read:

```C++
union Result
{
    int value;
    const char *error;
};

Result Parse(const char *str);
```

The problem with this is the caller cannot tell if the return `Result`
stores an integer `value` or string `error` message. Typically
untagged unions come with some way of telling which is stored.

Tagged Union Example
--------------------

First style is emedding the union in a structure and adding a selector field:

```C++
struct Result
{
    enum { Value, Error } type;
    union
    {
        int value;
        const char *error;
    };
};

Result x = Parse("123");
if (x.type == Result::Value)
    printf("An integer %d!\n", x.value);
else
    printf("Failed to parse: %s\n", x.error);
```

Or if the types do not intersect by determining from the actual
type. Hhere we take a lot of liberties in C++ and assume we've made
Integer and Error classes, and that we can use `dynamic_cast` to
determine the actual type of a pointer:

```C++
union Result
{
    void *ptr;
    Integer *value;
    Error *error;
};

Result x = Parse("123");
if (dynamic_cast<Integer *>(x.ptr))
    printf("An integer %d!\n", x->value);
else
    printf("Failed to parse: %s\n", x->error);
```

Set Theory Union
----------------

Some languages like [Ceylon], allow the use of a set-theory like union type constructor:

```C++
Int|String Parse(string);
```

Here the `|` operator means "either the first type OR the second
type", and represents a notional super-type of both types which can be
assigned values from either type and has only the common operations
allowed on both types.

Let us imagine that C++ is extended to include this `|` syntax, and
that `Int` and `String` only had the common super-type `Object`; this
might only provide equality and type testing operations.

Therefore in some imaginary C++ hybrid language we can now write:

```C++
Int|String x = 1;
Int|String y = "hello";

if (x == y)
    printf("Same value\n");
else
    printf("Not same value\n");
```

That is the variables `x` and `y` can only be assigned `Int` or
`String` values, but they can be compared assuming the super-type
`Object` of both `Int` and `String` has an `operator==` defined to
compare Object values.

If we also include the syntax:

* `x is Type` to return true only if `x` is of type `Type` or some
  sub-class of `Type` and false otherwise.

* `x as Type` to convert `x` to type `Type`, or cause a runtime error (exit, exception) if this
  is not allowed.

Now we could write this in a type safe manner:

```C++
Int|String x = Parse("123");
if (x is Int)
    printf("x=%d\n", x as Int);
else
    printf("Error: %s\n", x as String);
```

To simplify this, lets add a special version of the `if` syntax: `if
(x as Type) A else B` means "if x can be converted to Type then
execute A with x narrowed to Type, otherwise execute B with x narrowed
to the alternative type". Now we can simplify this to:

```C++
Int|String x = Parse("123");
if (x as Int)
    printf("x=%d\n", x);
else
    printf("Error: %s\n", x);
```

Note that on line 3, `x` has been succesfully narrowed to have type
`Int` and so can be printed as an integer. However if `x` is not of
type `Int` it must be of type `String` so on line 5 we can print the
error alternative.

Under the hood what actually might happen in the type deduction is a
little more complex in that `if (x as Type) A else B` might work as follows:

* If `x` (of type `T`) can be narrowed to type `Type` then:
  * Execute `A` where `x` is of type `T&Type`
  * Here `&` means "intersection or common sub-type".
  * In our case this is `(Int|String)&Int`, the only common sub-type would be `Int`.
* Otherwise
  * Execute `B` where `x` is of type `T&~Type`.
  * Here `~` means "every type other than".
  * In our case this is `(Int|String)&~Int`, the only common sub-type would be `String`.

Optional Types
==============

Some languages like [Ceylon] and [Swift] also include a special syntax and short hand for optional types.

The notation for optional type like `Int?` is short hand for
`Int|Null`, where `Null` is a special type which only has the `null`
pointer or reference as a valid value.  Almost all other types, such
as String do not allow a null pointer or reference to be assigned (the
exception is typically the `Object`, `Any` or `Top` type which is the
super-class of all types including `Null`).

Let's imagine we morph our C++-like language to include this syntax:

```C++
Int? Parse(String x);
```

Here `Parse` is a function which either parses the string as a number and returns the equivalent integer value, or it returns the `null` value (the only valid member of `Null` type).

Now we can write:

```C++
Int? x = Parse("123");
if (x is Int)
    printf("x=%d\n", x);
else
    printf("Error could not convert value\n");
```

Simplified Optional If Statements
---------------------------------

Lets also allow `if (x is T)` to be shortened to just `if (x)` where `x` is some optional `Type?` (some languages might have `exists` or `defined`):

```C++
Int? x = Parse("123");
if (x)
    printf("x=%d\n", x);
else
    printf("Error could not convert value\n");
```

We can now also place the assignment into the `if` statement as per C++:

```C++
if (Int? x = Parse("123"))
    printf("x=%d\n", x);
else
    printf("Error could not convert value\n");
```

Optional Define Operator
------------------------

Some languages like [Groovy], [Swift] and [Ceylon] include a way to
convert an optional value to a defined value.

In [Groovy] this is called the "Elvis Operator" and is written `?:`
(looks like a quiffed hair as modelled by Elvis). Here's an example:

```C++
Int? x = Parse("123");
Int y = x ?: 0;
```

The expression `x ?: y` means "if x is not null then use x (typed
without the Null) otherwise use y".

Optional Safe Navigation
------------------------

Often functions or methods which return an optional value are chained
to other methods which operate on those values. Here's a contrived
example which takes the integer 1, adds 1, then multiplies by 4 in a
method chain:

```C+++
Int x = 1.Add(1).Mul(4);
```

The value of this expression would be the `Int` value `8`.

Can we use the `Int? Parse(String)` function in this chain in place of
the value `1`? Not directly, since it returns either an `Int` or
`Null`.

Lets introduce a new syntax notation `x?.Method(...)` which means "if x is not null, define it to it's non optional type and call Method on it, otherwise don't call Method and evaluate to null".

In other words:

```C++
x?.Method(...) == if (x) x.Method(...) else null
               == if (x is ~Null) (x as ~Null).Method(...) else null"
```

We can now write:

```C++
Int x = Parse("1")?.Add(1)?.Mul(4);
```

Notice that `Parse("1")?.Add(1)` has type `Int?` since it can return
both `Int` from the call to the `Add` method or may return `Null`, and
therefore we still need to use `?.` to optionally call `Mul`.

Error Type
==========

By analogy to `Int?` meaning `Int|Null`, we might introduce a new
`Error` type and syntax for `Int|Error`. The short hand might be `Int!`.

The `Error` type would probably have a formatted message, and perhaps
a stack trace to discover where the error originated. It would
essentially be almost the same as exception types, though it would be
passed and returned from functions as an other value. Sub-types might
add extra detail where appropriate, for example `IOError` might
describe the input/output stream that caused the error.

We would also extend the short hand forms of `if`, `?:` and `?.` to
include both Null and Error types:

```C++
Int! x = Parse("123");
if (x)
    printf("x=%d\n", x);
else
    printf("%s:%d: Error: %s\n", x.GetFile(), x.GetLine(), x.GetMessage());
```

Other interesting properties of error might be useful:

* An `ErrorStack` which might wrap another deeper `Error`; useful for
  higher level components to wrap lower level errors.
* An `ErrorList` which might collect zero or more errors as one errors.
* Some sort of construct similar to `try` and `catch` to catch and
  handle errors within a block; much like exceptions.
* Something like "using" and "with" from languages like C# and Python
  where resources can be disposed automatically on error.
* Have alternate `!:` and `!.` chaining for just `Error`
  types, and leave `?:` and `?.` for `Null` values.
* Have `_` to mean the original value operated on by `?:`, `?.` (and `!:`, `!.`).
* The compiler might cause an compilation error if an `Error` return is ignored.

[semipredicate problem]: http://en.wikipedia.org/wiki/Semipredicate_problem
[union]: http://en.wikipedia.org/wiki/Union_type
[untagged union]: http://en.wikipedia.org/wiki/Union_type#Untagged_unions
[tagged union]: http://en.wikipedia.org/wiki/Tagged_union
[disjoint union]: http://en.wikipedia.org/wiki/Disjoint_union
[set theory union]: http://en.wikipedia.org/wiki/Union_(set_theory)
[programming with intersection types]: http://cis.upenn.edu/~bcpierce/papers/uipq.ps
[types and programming languages]: http://www.cis.upenn.edu/~bcpierce/tapl/
[ceylon]: http://ceylon-lang.org/documentation/1.1/tour/types/
[swift]: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Types.html
[groovy]: http://groovy.codehaus.org/Operators
