# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Subclasses of stdlib classes that are used to add additional data and methods
# to values loaded from features.
# 
# As objects get passed around through parameter types, steps, and the various
# helpers and utilities it becomes *very* useful to have context attached to 
# them, and this is how I went about it.
# 
module Wrappers
  
  # Wrapper subclass of {::Proc} that marks them to be used as the block 
  # argument when they show up as the last argument to a method call.
  # 
  class Block < ::Proc
  end # class Block
  
  
  # Wrapper subclasses around {::String}.
  # 
  # There's only one. I guess maybe I thought there were gonna be more when I
  # originally wrote this. I'm not so sure anymore, but it is how it is for now.
  # 
  module Strings
    
    # {::String} subclass used to mark it as being Ruby source code, with
    # instance methods added to evaluate it given the scenario object.
    # 
    # Special Case: Blocks
    # ------------------------------------------------------------------------
    # 
    # In addition to valid Ruby source, {Src} supports an additional special
    # format: Strings that start with `'&'` are made into {Block} instances.
    # 
    # The {Src} string is used as the block argument to {Block#initialize},
    # which allows it to evaluate in an expected manner and cast it to a
    # {Block}, differentiating it from a regular {::Proc} so it properly ends
    # up as the block argument when it needs to.
    # 
    class Src < ::String
      
      # Should we turn this string into a {Block}?
      # 
      # See notes in the {Src} class documentation.
      # 
      # @return [Boolean]
      # 
      def block?
        start_with? '&'
      end
      
      
      # Evaluate the source.
      # 
      # @param [::Object] self_obj
      #   The Cucumber scenario object. I saw it called `self_obj` in the Cuc'
      #   code somewhere, and stuck with it I guess.
      # 
      # @return [Block]
      #   If {.block?} is `true`.
      # 
      # @return [::Object]
      #   If {.block?} is `false`.
      # 
      def to_value self_obj
        if block?
          self_obj.scope_eval "#{ Block.name }.new #{ self }"
        else
          self_obj.scope_eval self
        end
      end # #to_value
      
    end # class Src
    
  end # module String
end # module Wrappers

# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
