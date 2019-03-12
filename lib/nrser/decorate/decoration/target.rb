# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Decorate
class   Decoration


# Definitions
# =======================================================================

# Internal structures that support `#call` and `#receiver` like a {::Method} out
# of a {Decoration} and that receiver to use as decoration targets.
#
# {Target}s are the glue between adjacent {Decoration} instances in a decorator
# stack, allowing an "up-stack" (called earlier) {Decoration} to bind the
# decorated call's receiver to the next "down-stack" (called later) {Decoration}
# in a `#call`-able instance to provide to it's {Decoration#decorator} as the
# `target` argument.
#
# We need to bind these two together in a callable regardless, and {Target}
# instances allow for better introspection of what's going on as things move
# through what can be a some-what confusing call process.
#
class Target
  
  # The "down-stack" {Decoration} that will be called with the {#receiver}
  # when this instance is {#call}ed.
  # 
  # @return [Decoration]
  #     
  attr_reader :decoration
  
  
  # The receiving object that will be passed to {#decorated}'s
  # {Decoration#call} when {#call} is, well, called.
  # 
  # @return [::Object]
  #     
  attr_reader :receiver
  
  
  # Construct a new {Target}, binding together 
  # 
  # @param [Decoration] decoration
  #   The {Decoration} that will be called when the instance is {#call}ed.
  # 
  # @param [::Object] receiver
  #   The decorated call receiver object to pass through to {#decorated}'s
  #   {Decoration#call}.
  # 
  def initialize decoration:, receiver:
    @decoration = decoration
    @receiver = receiver
  end
  
  
  # Proxy arguments through to the {#decorator}'s {Decoration#call}, prefixed
  # by {#receiver}.
  # 
  # @param [::Array<::Object>] args
  #   Arguments from up-stack calls, either directly from the decorated 
  #   method or preceding decorators.
  # 
  # @param [::Proc?] block
  #   Block argument from upstream.
  # 
  # @return [::Object]
  #   The response to pass back up.
  # 
  def call *args, &block
    decoration.call receiver, *args, &block
  end
  
end # class Target


# /Namespace
# =======================================================================

end # class   Decoration
end # module  Decorate
end # module  NRSER
