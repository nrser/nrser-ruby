# encoding: UTF-8
# frozen_string_literal: true

require_relative './type'

module NRSER::Types
  
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
  class Where < NRSER::Types::Type
    
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
    # @param [Proc<(V) => Boolean>] &predicate
    #   See {#predicate}.
    # 
    # @param **options (see NRSER::Types::Type#initialize)
    # 
    def initialize **options, &predicate
      super **options
      
      unless predicate.arity == 1
        raise NRSER::ArgumentError.new \
          "Predicate block must have arity 1",
          predicate: predicate,
          options: options
      end
      
      @predicate = predicate
    end
    
    
    # Test a value for membership.
    # 
    # @param  (see NRSER::Types::Type#test?)
    # @return (see NRSER::Types::Type#test?)
    # @raise  (see NRSER::Types::Type#test?)
    # 
    def test? value
      !!@predicate.call(value)
    end
    
  end # class Where
  
  
  # Get a type based on a predicate.
  # 
  def_factory :where do |**options, &predicate|
    Where.new **options, &predicate
  end
  
end # NRSER::Types
