# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/core_ext/method'

require_relative './type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================

# {Where} instances are predicate functions¹ as a type.
# 
# They have a {#predicate} block, and {#test?} calls it with values and
# returns the boolean of the result (double-bangs it `!!`).
# 
# Super simple, right? And easy! Why don't we just use these things all over
# the place?
# 
# If you're been around the programing block a few times, you probably saw
# this coming a mile away: you should avoid using them.
# 
# Yeah, sorry. Here's the reasons:
# 
# 1.  They're **opaque** - it's hard to see inside a {Proc}... even if you
#     got the source code (which seems like it requires gems and involves
#     some amount of hackery), that wouldn't really give you the whole
#     picture because you need to look at the binding as well... Ruby
#     procs capture their entire environment.
#     
#     Essentially, they suck to easily and/or comprehensively communicate
#     what they hell they do.
#     
# 2.  Like {When}, they're totally Ruby-centric... we can't really serialize
#     them and pass them off anywhere, so they're shitty for APIs and
#     property types and stuff that you may want or need to expose outside
#     the runtime.
#     
#     In this sense they're ok as implementations of types like {.file_path}
#     that represent an *idea* to be communicated to the outside world,
#     where each system that handles that idea will need to have it's own
#     implementation of it.
#     
#     Lit addresses a lot of this with serializable functions, but that's
#     nowhere near ready to rock, and support for it would probably be
#     added along side {Where}, not in place of it (since {Where} is
#     probably still going to be used and useful).
# 
# So please be aware of those, and be reasonable about your {Where}s.
# 
# > ¹ I say *functions*, because they really *should* be functions (same
# > input always gets same output, pure, etc.).
# >
# > Yeah, there's not much stopping you from making them state-based or
# > random or whatever, but please don't do that shit unless you've really
# > thought it through. And if you still do, please write me and tell me
# > what you thought and why it's a reasonable idea and I'll update this.
# 
class Where < Type
  
  # Predicate {Proc} used to test value for membership.
  # 
  # @return [Proc<(V) => Boolean>]
  #   Really, we double-bang (`!!`) whatever the predicate returns to
  #   get the result in {#test?}, but you get the idea... the response will
  #   be evaluated on its truthiness.
  # 
  attr_reader :predicate
  
  
  # Make a new {Where}.
  # 
  # @note
  #   Documentation and examples are indented to illustrate behavior and
  #   aid in development. Please use the factory method {Types.where} to
  #   create instances - they allow us to easily improve and optimize 
  # 
  # 
  # @overload initialize method, **options
  #   
  #   This is the preferred form, where a bound method provide the membership
  #   predicate.
  #   
  #   Class or module methods make the most sense, though this is not enforced.
  #   
  #   @example Create a {Type} that tests if a path is a file
  #     type = Where.new File.method( :file? )
  # 
  #   @param [Method<(Object)=>Boolean>] method
  #     Arity 1 bound method that will be used to decide membership (if it 
  #     responds truthy then the argument is a member of the type).
  #   
  #   @param **options
  #     Additional options that will be passed up to {Type#initialize}.
  # 
  # 
  # @overload initialize **options, &block
  #   
  #   This form should be used sparingly - please use a bound class or module
  #   {Method} instead of an opaque `&block` for the predicate.
  #   
  #   it exists mostly for legacy reasons, and for the 
  #   
  #   @param [String] name:
  #     In this form, a `name` is required because it is not usually possible 
  #     to extract any descriptive information from the `&block`.
  # 
  #   @param **options
  #     Additional options that will be passed up to {Type#initialize}.
  # 
  #   @param [Proc<(Object)=>Boolean>] &block
  #     Arity 1 {Proc} that will be used to decide membership (if it responds 
  #     truthy then the argument is a member of the type).
  #   
  # 
  def initialize method = nil, **options, &block
    # Check up on what we got

    if method && block
      raise NRSER::ArgumentError.new \
        "Can't supply both method", method, "(first arg)",
        "and &block", block
      
    elsif !method && !block
      raise NRSER::ArgumentError.new \
        "Must provide either a Method<(Object)=>Boolean> as the first argument",
        "*or* a Proc<(Object)=>Boolean> as the block"
      
    end

    @predicate = method || block
    
    unless predicate.arity == 1
      raise NRSER::ArgumentError.new \
        "{NRSER::Types::Where} predicates must have arity 1",
        predicate: predicate,
        arity: predicate.arity,
        options: options
    end

    unless options[:name]
      if predicate.is_a?( Method )
        options[:name] = predicate.full_name
      else
        raise NRSER::ArgumentError.new \
          "`name:` keyword argument is required when creating {Where}",
          "from `&block` predicates."
      end
    end

    super **options

  end
  
  
  # Test a value for membership.
  # 
  # @param  (see Type#test?)
  # @return (see Type#test?)
  # @raise  (see Type#test?)
  # 
  def test? value
    !!@predicate.call( value )
  end


  # A string that is supposed to give our best concise description of the type.
  # 
  # {Where} sucks because we can't really do much here.
  # 
  # @return [String]
  # 
  def explain
    "#{ self.class.demod_name }<#{ @name }>"
  end
  
end # class Where ************************************************************


# Get a type based on a predicate.
# 
def_factory :where do |*args, &block|
  Where.new *args, &block
end


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
