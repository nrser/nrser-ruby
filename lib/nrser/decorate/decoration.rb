# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Project / Package ###

# For binding sub-decorations with receivers for calling
require_relative './decoration/target'


# Namespace
# =======================================================================

module  NRSER
module  Decorate


# Definitions
# =======================================================================

# Internal structure that holds necessary data for a single method decoration
# step.
#
#
# What..? Why..?
# ----------------------------------------------------------------------------
#
# The whole {NRSER::Decorate} internals have been object-oriented to hell,
# because the whole thing can get confusing really quickly, with all the
# different calls and callables and decoration "stack" layers, and this approach
# gives me a lot of space to break things up, try my best to name things
# reasonably, and provide a ton of documentation for my later self or whatever
# other poor soul (hi!) has to happen back in here and try to sort out what the
# fuck is going on.
#
# My hope is these objects will also aid in debugging by providing considerably
# more insight into what is going where and why than a bunch of lambdas and
# crap.
#
# Your millage may vary.
#
#
# Overview
# ----------------------------------------------------------------------------
#
# A {Decoration} holds a {#decorator} and a {#proto_target}. It receives calls
# at {#call} and is responsible for invoking the {#decorator} with the call's
# arguments and/or block, as well as a callable *target* for the method it
# wraps, so the decorator can call that, if and when and how it likes, which is
# pretty much the point of decorators.
#
# The response from that {#call} is what goes back towards the original call
# site.
#
#
# Simple Example
# ----------------------------------------------------------------------------
#
# In a simple case, if we have a method `A.f` that we decorate with some other
# method `g`, a single {Decoration} `d` is constructed with `<Method g>` as the
# {#decorator} and `original_A_f = <Method A.f>` as the {#proto_target}.
#
# The decoration process that constructed the {Decoration} (see
# {Decorate.decorate}) will have overwritten `A.f` to the equivalent of:
#
# ```ruby
# def A.f *args, &block
#   d.call self, *args, &block
# end
# ```
#
# When `A.f` is called with some `args` and `block`, `d.call` is called with `A`
# as the `receiver` followed by those same `args` and `block`.
#
# The {Decoration} then does some work with the {#decorator} and #{proto_target}
# to make sure they're ready for calling, like binding {::UnboundMethod}s, and
# additional stuff for stacked/chained decorations (check out
# {#decorator_callable_for} and {#target_for} for more details), but in this
# simple case, no "call-time" work is needed, so it just proceeds with the call.
# 
# The {#decorator} `g` is called through `d.decorator`, with the *original*
# `A.f` in the first position as the *target*, followed by the `args` and 
# `block`:
#     
#     d.decorator( d.proto_target, *args, &block )
# 
# which is equivalent to
# 
#     g( original_A_f, *args, &block )
# 
# and that response is returned back to whatever called the decorated `A.f`
# with those `args` and `block`.
# 
# Inside of `g`, it can decide what to do with the original `A.f` and the call's
# arguments and block - the usual decorator shit.
# 
# 
# Going Deeper...
# ----------------------------------------------------------------------------
# 
# Things start to get more complicated when you introduce {::UnboundMethod}s 
# into the mix, as well as stacked/chained decorations, but it's pretty much
# just the stuff that needs to happen in order to achieve that same general
# behavior.
# 
# Check out the source and documentation, as well as the
# {requirements::features::lib::nrser::decorate Features} for further info.
#
class Decoration
  
  # Attributes
  # ==========================================================================
  
  # The decorator, which is either a `#call`-able or an instance method that
  # must be first bound to the receiver at call-time.
  # 
  # If the decorator is bound to a receiver (*is not* an {::UnboundMethod})
  # then it should expect to be `#call`-ed with the target (the next "down
  # the stack" callable) in first position, followed by any arguments and/or
  # `&block`, and it's response will be passed back "up stack" - to the 
  # original caller itself or whatever up-stack decorator invoked this one
  # (which may of course alter the response or respond however it chooses).
  # 
  # If the decorator is unbound (*is* an {::UnboundMethod}), then when bound 
  # it expected to do the same.
  # 
  # I know that's hard to follow, so here's some pseudo code that may help:
  # 
  # **Bound** decorators should be callables like:
  # 
  #     .call( target, *args, &block ) → RESPONSE
  # 
  # **Unbound** decorators should be callables that work like:
  # 
  #     .bind( receiver ) → .call( target, *args, &block ) → RESPONSE
  # 
  # @return [::UnboundMethod]
  #   The decorator is an instance method that will need to be bound to the
  #   calling instance, which will not be known until that time (in {#call}).
  #   
  # @return [::Method]
  #   The decorator is a bound method, which is ready to call without knowing
  #   the call-time receiver. It may be a singleton method of the {::Module}
  #   containing the end-target method, but it does not need to be.
  #   
  #   Methods are `#call`-able, but I thought it worth breaking out in the 
  #   docs since it's a common decorator type.
  # 
  # @return [#call<(target, *args, &block) → ::Object]
  #   The decorator is any {::Object} with a `#call` method.
  #   
  #   When the decorated method is called, it will be called instead with 
  #   the call's receiver, the next-down the stack target callable
  # 
  attr_reader :decorator
  
  
  # The object used to construct the target - the next `#call`-able 
  # "down stack" - that will be provided to the {#decorator} so it can 
  # proceed to call "down" (if it chooses, of course).
  # 
  # The proto-target may already be a suitable target, or it may need to be
  # turned into one at call-time given the call receiver.
  # 
  # @return [::Method]
  #   A bound method, presumably of the receiving object, through it totally 
  #   could be from any other as well.
  #   
  #   In this case, the proto-target is already a suitable target, and 
  #   {#target_for} will simply return it.
  # 
  # @return [::UnboundMethod]
  #   An instance method is next down the call stack, which will be bound to 
  #   the decorated call receiver at call-time to produce the actual target 
  #   {::Method} (see {#target_for}).
  #   
  # @return [Decoration]
  #   Another decoration is next down the call stack.
  #   
  #   A {Target} will be constructed from this other {Decoration} at call-time 
  #   given the call receiver, which this next-down {Decoration} may need to 
  #   bind  any {::UnboundMethod}s in it or still further {Decoration}s.
  # 
  attr_reader :proto_target
  
  
  # Construction
  # ==========================================================================
  
  # Construct a {Decoration}.
  # 
  # @param [::UnboundMethod | ::Method | #call]
  # 
  def initialize decorator:, proto_target:
    # Check that shit...
    
    unless  decorator.is_a?( ::UnboundMethod ) ||
            decorator.respond_to?( :call )
      raise TypeError.new \
        "`decorator:` arg must be an", ::UnboundMethod, "or be `#call`-able",
        decorator: decorator
    end
    
    case proto_target
    when Decoration, ::UnboundMethod, ::Method
      # pass, it's ok
    else
      raise TypeError.new \
        "`proto_target:` arg must be a:", Decoration, ::UnboundMethod, ::Method,
        proto_target: proto_target
    end
    
    # ...and assign:
    
    @decorator = decorator
    @proto_target = proto_target
    
  end # #initialize
  
  
  # Get the `#call`-able decorator object given the decorated method call 
  # `receiver`.
  # 
  # If the {#decorator} is an {::UnboundMethod} (instance method), then it is
  # bound to `receiver` and the resulting {::Method} is returned.
  # 
  # Otherwise, {#decorator} is already `#call`-able and is simply returned.
  # 
  # @return [#call<( #call<(*args, &block) → ::Object>, *args, &block ) → ::Object>]
  #   Decorator object that will be `#call`ed with `( target, *args, &block )`,
  #   where `target` is the response from {#target_for}.
  # 
  def decorator_callable_for receiver
    if decorator.is_a? ::UnboundMethod
      decorator.bind receiver
    else
      decorator
    end
  end
  
  
  # Turn {#proto_target} into a `#call`-able target that will be passed to the
  # {#decorator} so it can hand-off down the stack (if it chooses to).
  # 
  # We may need the decorated call receiver in order to bind instance method
  # {#proto_target}s into {::Method}s or construct {Target}s for other 
  # {Decoration}s.
  # 
  # @param [::Object] receiver
  #   The `receiver` argument that was passed to {#call}.
  #   
  # @return [#call<(*args, &block) → ::Object>]
  #   A `#call`-able object ready to accept the arguments and block. It may be
  #   the original method that was decorated or represent an intermediate 
  #   object in a decoration stack.
  # 
  def target_for receiver
    case proto_target
    when Decoration
      # This decoration is stacked on top of another decoration, which happens
      # when decorating with multiple decorators at once.
      #
      # In this case, we want to construct a {Target} with that down-stream
      # {Decorator} and the `receiver` so the {Target#call} calls
      # {#proto_target}'s {#call}.
      #
     Target.new decoration: proto_target, receiver: receiver
     
    when ::UnboundMethod
      # The proto-target is an instance method, so it needs to be bound to the
      # receiver to create a callable object in the way that decorators expect.
      # 
      proto_target.bind receiver
    
    else
      # Proto-target should already be ready to call - it may be a {::Method}
      # reference or any other `#call`-able object.
      proto_target
    end
  end # #target_for
  
  
  # Invoke the decorator. This is what is called when the decorated method is.
  # 
  # The receiver of the call may be needed in order to bind instance methods
  # along the way through the decoration stack, as it could of course not be
  # known in that case when the decoration was done at the module/class level.
  # 
  # @param [::Object] receiver
  #   Receiving object when the decorated method was called.
  #   
  #   For example, if `A.f` is decorated, then `A.f` is called, `receiver` will
  #   be the `A` module (or class).
  #   
  #   If `A#g` is decorated, then a new `a = A.new` instance is constructed,
  #   and `a.g` is called, then `receiver` will be the `a` instance.
  # 
  # @param [::Array<::Object>] args
  #   Arguments given when the decorated method was called.
  #   
  #   For example, if `A.f` is decorated, then `A.f( 1, 2, 3 )` is called, 
  #   `args` will be `[ 1, 2, 3 ]`.
  # 
  # @param [::Proc?] block
  #   Block given when the decorated method was called.
  #   
  #   For example, if `A.f` is decorated, then `A.f &some_proc` is called, 
  #   `args` will be `some_proc`.
  # 
  # @return [::Object]
  #   Response from the decorator.
  # 
  def call receiver, *args, &block
    decorator_callable_for( receiver ).call \
      target_for( receiver ),
      *args,
      &block
  end
  
end # class Decoration


# /Namespace
# =======================================================================

end # module  Decorate
end # module NRSER
