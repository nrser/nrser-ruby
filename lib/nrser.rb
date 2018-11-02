# Requirements
# =======================================================================
# 
# I'm moving to "just require everything" after abandoning the idea of
# supporting old rubies (2.3 is now min), so all the require expressions
# should just go here, making life much simpler.
# 

# Stdlib
# -----------------------------------------------------------------------
require 'pathname'
require 'set'
require 'pp'
require 'ostruct'
require 'json'
require 'yaml'
require 'singleton'

# Deps
# -----------------------------------------------------------------------
require 'hamster'

### Active Support
# 
# We're not going to import all of it, but here we'll import the stuff we
# always want to use and then add pieces in places as needed.
# 
require 'active_support/json'
# require 'active_support/core_ext/object/json'


# Hi there!
# 
# This is [my][me] Ruby stuff.
# 
# [me]: https://github.com/nrser
# 
# This module has a lot of static methods (`class` or `self.` methods), which
# are functional (pure).
# 
# They're all just directly attached to the {NRSER} object to make them
# convenient to call, but they're grouped here by what they operate on.
# 
# You can go ahead and use them like that, but many (most?) of them are also
# refined in to the classes of their first arguments in `nrser/refinements`,
# which is how I mostly use them, unless I'm targeting an older Ruby that
# doesn't support refinements.
# 
# There are also various classes and sub-modules as well. Most of the
# sub-modules require refinements because though it's nice to have the core
# functionality available in a pinch for earlier Rubies, I'm not targeting
# versions that far back in any serious or complicated code.
# 
# Enjoy!
# 

# Load up version, which has {NRSER::ROOT} in it and depends on nothing else
require_relative './nrser/version'

# Base core ext used to sugar up dynamic method binding for `nrser/ext` modules
require_relative './nrser/core_ext/object/nrser_ext'

# {Module.safe_name} is really useful all around, including in logging
# TODO  Switch to `n_x`?
require_relative './nrser/core_ext/module/names'

# Then logging can come in...
require_relative './nrser/log'

# Then everything else...
require_relative './nrser/char'
require_relative './nrser/errors'
require_relative './nrser/gem_ext/hamster'

require_relative './nrser/no_arg'
require_relative './nrser/message'
require_relative './nrser/collection'
require_relative './nrser/shortcuts'
require_relative './nrser/functions'
require_relative './nrser/types'
require_relative './nrser/meta'
require_relative './nrser/props'
require_relative './nrser/mean_streak'
