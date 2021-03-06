About NRSER::Types
========================================================================

Ah, Neil's Shitty Type System (NSTS).

Kinda like [tcomb][], but for for Ruby, and worse.

Anyways I needed this because I needed some re-usable way for things to make sure they were in some reasonable state at runtime. And it kind-of works for that so far.

[tcomb]: https://github.com/gcanti/tcomb


Structure & Design
------------------------------------------------------------------------

At the bottom of everything, there are *type classes*... which are Ruby classes
that descend from {NRSER::Types::Type}. We call instances of these classes
*types*.

Types essentially do one thing: they have a {NRSER::Types::Type#test?} method
that accepts a single arguments and returns a boolean. If the type returns
`true` when `#test?` is called with an object, then that object is a member of
that type. That's it.

Some of those classes, like the universal type {NRSER::Types::Top} - of which
every object is a member ({NRSER::Types::Top#test?} always returns `true`) - are
essentially singletons, but many type classes parameterize over values that
instances hold as variables.

Types are designed to fundamentally immutable once constructed, through the 
standard practice of storing state in instance variables without write 
functions (of course, use of methods like `#instance_variable_set` will still
mutate types - please don't do this, since any future caching will likely 
reuse instances).

API is basically a collection of module class methods attached to
{NRSER::Types}, like {NRSER::Types.str} or {NRSER::Types.non_neg_int}.


### Type Maker Method Names

I generally went with "short" type names, IDK, to keep things short, and maybe to conflict a bit less with other common names in Ruby.

Some examples:

-   `str`
-   `bool`
-   `non_neg_int`

You get the idea. Many have their longer names added as aliases, which I like... would rather have it "just work" with what you type than have to remember what exactly we chose to call stuff.


### What to Expect

These method should all return {NRSER::Types::Type} instances, though many will use a refined subclass of {NRSER::Types::Type} like {NRSER::Types::Bounded} or whatever.

I picked this functional approach over a more I guess standard object-oriented architecture - where every type would be it's own class and you would instantiate them - because it's along the line of how [tcomb][] is designed and I think it works pretty well there. It also provides a lot of flexibility as far as combinators and such: we will return a {NRSER::Types::Type} that meets your needs, making no further contract, which allows us a lot more freedom to muck around in the back end.


### Them Options

The {NRSER::Types} module methods should all accept a `options` hash as the last argument that will eventually find it's way up to {NRSER::Types::Type#initialize}. Many should accept other arguments as it makes sense.

In cases where the type maker method wants a keyword hash of it's own, I think I've been separating them out into two arguments, like:

    def some_type kwds, options = {}
      ...
    end

which is a bit of a pain 'cause you gotta use parens if you want to pass options as well as keywords:

    some_type( {x: 1, y: 3}, name: 'SomeType' )

but you don't run into any conflicts between options and keywords or whatever else, and it's nice to just pick a style and stick with it rather than have to do one or two different 'cause of a conflict.


