NRSER Ruby lib
========================================================================

Basic Ruby utilities I use in a lot of stuff.

These tools are hastily written or copied from other sources. 

They are not fast.

They are not optimized.

They are largely untested. Though this *is* slowly getting better.

Proceed with caution.


------------------------------------------------------------------------
Installation
------------------------------------------------------------------------

Add this line to your application's Gemfile:

    gem 'nrser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nrser


------------------------------------------------------------------------
Design
------------------------------------------------------------------------

1.  No monkey-patching (`core_ext` kinda stuff).
    
    All language extension is done with refinements.
    
    Refinements are funky in a few ways, but they make me feel better.
    
2.  As a corollary, (pretty-much) all refinement methods are implemented functionally so they can be used in older Rubies (2.0 and before I think?).
    
    This is pretty much only an issue with the current system Ruby version on macOS, which is `2.0.0`.
    
    I don't run into it much, but it's nice to have it when you need it, and has panned-out to be a decent design philosophy.

3.  This means that code in the `NRSER` gem itself can't use the refinements it provides.
    
    Which sucks, but I can live with it, because the times that I need some Ruby when I've only got the macOS system installation available I really wants it.
    
    -   The exception is the types system, which uses the refinements, and will thus be unavailable in old-ass rubies.
    
4.  Basically all these methods are defined directly on the `NRSER` module for the sake of brevity and connivence, though their definitions are split up across many files and directories by subject.
    
    I like this because I like small files. They make it easier to see what's changing in commits at a glance, and I find them easier to work with in the GUI editors that I use.
    
    The fact that Ruby does not tie source file location to API path is one of my favorite parts of the language.
