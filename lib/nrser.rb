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
require 'logger'
require 'singleton'


# Deps
# -----------------------------------------------------------------------
require 'hamster'

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
module NRSER
  
  # Absolute, expanded path to the gem's root directory.
  # 
  # @return [Pathname]
  # 
  ROOT = ( Pathname.new(__FILE__).dirname / '..' ).expand_path
  
end

require_relative './nrser/ext'
require_relative './nrser/errors'
require_relative './nrser/version'
require_relative './nrser/no_arg'
require_relative './nrser/message'
require_relative './nrser/env'
require_relative './nrser/collection'
require_relative './nrser/functions'
require_relative './nrser/types'
require_relative './nrser/refinements'
require_relative './nrser/meta'
require_relative './nrser/mean_streak'
