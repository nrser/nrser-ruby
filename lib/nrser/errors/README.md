About `nrser/errors`
==============================================================================

{NRSER}'s error pseudo-module (everything in this directory is namespaced
directly under {NRSER} for brevity) is centered around the {NicerError}
mixin, which, well... tries to make working with errors a little nicer.

It includes:

1.  "Nice" extensions of some builtin error classes:
    1.  {NRSER::AbstractMethodError} < {::NotImplementedError}
        -   For when an abstract method is mistakenly called.
    2.  {NRSER::ArgumentError} < {::ArgumentError}
        -   A nice extensions of a familiar favorite.
    3.  {NRSER::TypeError} < {::TypeError}
        -   A nice why to say they're not my type. Used extensively in 
            {NRSER::Types}, which is kind of like Tinder profiles for Ruby 
            objects.
2.  New "nice" extensions of {::StandardError}, and extensions of them:
    1.  {NRSER::ValueError} < {::StandardError}>
        -   For when a problem is discovered with a value that is not an 
            argument, and the problem is not it's type.
    2.  {NRSER::AttrError} < {NRSER::ValueError}
        -   Raise me when there's an issue with a attribute of an object.
    3.  {NRSER::CountError} < {NRSER::AttrError}
        -   For when `#count` doesn't add up. I know, this one is weirdly
            specific, but it solved something from what I remember.

You can check out the doc-strings to those various classes for details. For the
rest of this I'm going to focus on what the {NRSER::NicerError} mixin brings to
the table.

Let's check out some of the nicer features!


1.) API Compatibility with Built-In Errors
------------------------------------------------------------------------------

This one is important. {NRSER::NicerError} strictly enhances the standard Ruby
{Exception} API, meaning those classes can still be constructed with the

    MyError.new( message_string )

form, and produce the error they should show at `MyError#message` and
`MyError#to_s`. Everything else is added on and optional, should you chose to
use it, though you will of course pay some slight performance penalty using
nicer errors in that way over the built-in classes.

I also want to stick with this policy for mixing classes unless they are very
specifically focused, like {NRSER::Types::CheckError}, which requires `value`
and `type` keyword arguments, and things like a hypothetical HTTP error that
requires the status code, etc., and want to extend the policy to cover the
{NRSER::NicerError} general construction form:

    MyError.new *message, details:, **context

With general errors for general use, I've found it sucks to try and remember 
various parameter forms and how they get stitched together when you're on a 
roll or in a hurry, and I know it will impose even more overhead on people that
didn't write the library.

Errors should be easy as possible to use; they're already kind-of a pain as is.


2.) Splat `message`
------------------------------------------------------------------------------

Accept an variable amount of positional arguments as a `message` {Array}
instead of just a string, dumping non-string values and joining everything
together.

This lets you deal with printing/dumping all in one place instead of
adding `#to_s`, `#inspect`, `#pretty_inspect`, etc. all over the place.

Write things like:

    MyError.new "The value", value, "sucks, it should be", expected

This should cut down the amount of typing when raising as well, which is
always welcome.

It also allows for a future where we get smarter about dumping things, offer
configuration options, switch on environments. For example, you might want to
produce rich messages with detailed dumps that take more time to format and
space to store while developing and produce concise messages that are cheap
to produce and store in production.

> Of course, in line with (1), you can always string-format elements of
> `message` yourself, and the resulting strings will be joined into the final
> message. You can also just pass a single string like Ruby's builtin
> exceptions, maintaining the same API.


3.) "Extended" Messages - `details` and `context`
------------------------------------------------------------------------------

The normal message that we talked about in (2) - that we call the *summary
message* or *super-message* (since it gets passed up to the built-in
{StandardError#initialize}) - is intended to be:

1.  Very concise
    -   A single line well under 80 characters if possible.
        
    -   This just seems like how Ruby exception messages were meant to be, I
        guess, and in many situations it's all you would want or need
        (production, just gets rescued anyways, there's no one there to read it,
        etc.).
        
2.  Cheap to render and store.
    -   We may be trying to do lot very quickly on a production system.

However - especially when developing - it can be really nice to add
considerably more detail and feedback to errors.

To support this important use case as well, {NRSER::NicerError} introduces the
idea of an *extended message* that does not need to be rendered and
output along with the *summary/super-message*.

Extended messages are rendered on-demand, so systems that are not configured to
use it will pay a minimal cost for it's existence.

> See {NRSER::NicerError#extended_message}.

The extended message is composed of:

1.  Text *details*, optionally rendered via {Binding#erb} when a
    binding is provided.

2.  A *context* of name and value pairs to dump.
    
Both are provided as optional keyword parameters to
{NRSER::NicerError#initialize}.

Those values may be accessed via {NRSER::NicerError#details} and 
{NRSER::NicerError#context}, and rendered to strings 


3.) Default Message
------------------------------------------------------------------------------

While (1) lets you know you should always be able to use the Ruby and nicer 
construction forms on all but super-specific errors, {NRSER::NicerError} also
gives you the option of brevity with support for *default messages*, which
are constructed when no positional `message` arguments are passed to its
constructor.

Default messages presumably use the values of some well-known context values to
render the user-facing string, and degrade into some sort of complaint if
they're absent (someone could always be a wanker and call `MyError.new`, in
which case you're left with little resort but tell them so).

You can define default message behavior by overriding `#default_message` after
mixing-in {NRSER::NicerError}. Please practice caution in this - as well as 
all error methods: don't cause errors when handling errors.
