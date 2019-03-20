# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ============================================================================

### Stdlib ###

require 'set'


# Namespace
# =======================================================================

module  NRSER
module  Support


# Definitions
# =======================================================================

# Helpers for "critical" code - places we would really rather do anything than
# fail and/or can't depend on anything else being in place yet.
# 
# Some down-right nasty code, but it seems better to have it centralized and 
# standardized rather than half-assed all over the place. It's going to need
# changes and improvements as it get battle-tested, but at least there will
# be one place to do it, and code that needs this functionality will be clearly
# marked.
# 
# Saying Something (Logging without {NRSER::Log})
# ----------------------------------------------------------------------------
# 
# Uses {::Kernel#warn} to tell the world what's going wrong, allowing it to be
# used in logging and it's dependencies.
# 
# (Not) Raising Errors
# ----------------------------------------------------------------------------
# 
# Methods in this module not raise any errors, except those listed in 
# {CriticalCode::DONT_RESCUE}, which seem to me like they indicate conditions
# that should not be squashed: program trying to exit, failure to allocate 
# memory, a signal being received.
# 
# This is just my first inclination after looking over the list of built-in
# {::Exception} subclasses, and may need improvement, especially since they're
# probably uncommon occurrences in real-world use.
# 
# I'm going to add some additional details in the {CriticalCode::DONT_RESCUE}
# doc-string.
# 
# A Note On Cost
# ----------------------------------------------------------------------------
# 
# This is all relatively *very* expensive... *lots* of nested `begin/rescue`
# blocks. Maybe it will be improved in the future, but it still won't be free.
# 
# I would say the aim, now and in future optimizations, is to make the *good*
# path - the path where nothing goes wrong (nothing raises) - fast, and make 
# *bad* path - the path where things do go wrong and errors are raised - safe,
# safe meaning that all errors that should be handled are handled and reported
# and the method returns without raising.
# 
# I hope it is obvious that these methods should not be used with code that 
# expects to raise errors, and if it is, it should not expect it to be fast 
# when they do.
# 
module CriticalCode
  
  # Constants
  # ==========================================================================
  
  # {::Exception} classes to bubble up; everything else gets rescued and 
  # reported (via {::Kernel#warn}) if possible.
  # 
  # 1.  {::SystemExit} - Attempting to exit the program doesn't seem to me like 
  #     something that happens much by accident, and I've had weird and 
  #     frustrating issues due to swallowing {::SystemExit} errors.
  #     
  #     So, here, for now, if you really got to go, you go to go. Re-raise!
  #     
  # 2.  {::NoMemoryError} - We don't see this guy so much these days, but if we
  #     really can't allocate memory, we probably aren't going to get much of
  #     anything done.
  #     
  # 3.  {::SignalException} - To be honest, I don't program with signals much,
  #     so I'm kinda guessing here... but I know signals show up when you try to
  #     terminate a program from outside, so I'm going to think of it like that 
  #     until I have a better way, which puts it in the same category as 
  #     {::SystemExit} for me.
  #     
  #     If you really got to go, you got to go.
  #     
  # This leaves all of {::StandardError}, as well as {::ScriptError}, 
  # {::SecurityError} and {::SystemStackError} as being squashed.
  # 
  # Regarding the less common two in particular: for {::SecurityError}, the 
  # security situation has already been bailed out of, so it seems like we 
  # should be able to attempt to carry on.
  # 
  # I can imagine some possible weirdness with {::SystemStackError}, which 
  # usually means an infinite loop in practice, but, again, we've already left
  # whatever situation it was happening in, and if it happens again in the 
  # final, simple attempt to {::Kernel#warn} it will get get bubbled up, so it
  # seems reasonable, at least to start.
  # 
  # @return [::Set<::Class<::Exception>>]
  #   Set of {::Exception} subclasses that will be re-raised.
  # 
  DONT_RESCUE = Set[
    ::SystemExit,
    ::NoMemoryError,
    ::SignalException,
  ]
  
  
  # Instance Methods
  # ==========================================================================

  protected
  # ========================================================================
    
    # Wrapper around {::Kernel#warn} to try to let someone know that something
    # has gone wrong. Presumably the `error` will not be raised.
    #
    # This is useful in logging and it's dependencies that can't count on normal
    # error reporting being available.
    # 
    # @note
    #   You probably want to use {#try_critical_code} rather than use this 
    #   method directly. If you screw up your arguments 
    # 
    # @param [::Array<#to_s>] messages
    #   User messages to add to the warning.
    #   
    #   Passes them as arguments to {::Kernel#warn}, which seems like it calls
    #   `#to_s` on anything that is not a {::String}, so unless you have objects
    #   that raise in their `#to_s` they should be ok ({::Kernel#warn} looks
    #   like it pretty much just does a `$stderr.puts *args`).
    #   
    #   If this is empty, we'll stick a generic message in for ya.
    #   
    # @param [::Exception] error
    #   The error you want to warn about.
    # 
    # @return [nil]
    # 
    # @raise
    #   This method does not expect to raise any errors.
    #   
    #   If any of {DONT_RAISE} are raised during execution, they will be 
    #   allowed to bubble up.
    #   
    #   The method attempts to briefly report any other errors (which may stem 
    #   from bad arguments, etc.) using {::Kernel#warn}. If errors are raised 
    #   in that section, they will bubble up.
    #
    def warn_of_critical_code_error *messages,
                                    error:,
                                    print_backtrace: true
      args = [
        "**WARNING** Error raised in critical code",
        *messages,
        "ERROR: #{ error } (#{ error.class })"
      ]
      
      if print_backtrace
        backtrace_string = begin
          if error.backtrace
            error.backtrace.join( "\n  " )
          else
            "(no backtrace)"
          end
        rescue
          "(failed to format backtrace)"
        end
        
        args << backtrace_string
      end
      
      args << "**END WARNING**"
      
      warn *args
      
      return nil
    rescue *DONT_RESCUE
      raise
    rescue ::Exception => really_bad
      warn  "{NRSER::Support::CriticalCode#warn_of_critical_code_error} ITSELF",
            "raised an ERROR: #{ really_bad } (#{ really_bad.class })"
      nil
    end # #warn_of_critical_code_error
    
    
    # Run a block of code, rescuing and warning about (most) all errors.
    #
    # For use in critical areas like logging and errors themselves where you
    # really just want to keep going if in any way reasonable.
    #
    # If everything goes alright, the result of the `&block` is returned.
    #
    # If something goes wrong, in the `&block`, or anywhere else, it will be
    # reported via {#warn_of_critical_code_error}, which wraps {::Kernel#warn},
    # and `nil` will be returned.
    #
    # This means there is no way for the caller to distinguish between something
    # having failed and `nil` being returned. This might turn out to be a dumb
    # idea, but it's intentional for now.
    #
    # I think it makes some sense... you are executing some code, trying to get
    # something to use in some way, but if anything goes wrong you end up with
    # nothing. If nothing goes wrong and what you get back is *still* nothing,
    # that is fundamentally the same: you got nothing, and you can't really do
    # much of anything with it.
    # 
    # If you need to make decisions based on whether something worked or not,
    # you should be doing those tests and branches in the code in question. For
    # now, at least. I could see adding a Go-style version that returns an
    # `[error, result]` pair, but I don't want to over-engineer at this point.
    # 
    # @overload try_critical_code *args, &block
    #   This is the actual signature for the method, defined as such so that 
    #   calls don't raise before we have a chance to handle them.
    #   
    #   The other overload is the effective signature (how you should *think*
    #   about calling it).
    #   
    #   @param [::Array] *args
    #     Accepts a splat to avoid {::ArgumentError}s getting raised before we 
    #     even get into the method. See the other overload for the effective 
    #     parameters, as well as the rest of the doc.
    # 
    # @overload try_critical_code print_backtrace: true, get_message: nil, &block
    #   The *effective* signature for the method. Argument checking is done
    #   by hand and errors are reported via {#warn_of_critical_code_error}.
    #   
    #   If there are errors with the keyword arguments, they are reported and
    #   the method continues on with the defaults.
    #   
    #   If the `&block` is missing, it is reported and `nil` is returned (as 
    #   there's not really much else that can be done in that case).
    #   
    #   @param [Boolean] print_backtrace
    #     Passed to {#warn_of_critical_code_error} when something is raised,
    #     controls if the backtrace will be printed.
    #   
    #   @param [nil | (#call & #arity)] get_message
    #     Optional `#call`-able to get the message(s) to pass to
    #     {#warn_of_critical_code_error} when an error is raised.
    #     
    #     Only called if an error is raised.
    #     
    #     It's `#arity` is checked before calling: if it's `0`, it's called with 
    #     no arguments. Otherwise, it's called with the {::Exception} as the
    #     only argument.
    #     
    #     It's response is "splatted" into the `*messages` argument of
    #     {#warn_of_critical_code_error}. In practice it means the response
    #     can be a single object or an {::Array} of objects, all of which will
    #     be turned into {::String} via their `#to_s` if they aren't already.
    #   
    #   @param [::Proc<() → ::Object>] block
    #     The block to execute. It is given no arguments.
    #     
    #     If the block is missing, a warning will be issued and `nil` will be
    #     returned.
    #   
    #   @return [::Object]
    #     When nothing goes wrong (nothing is raised), the response of the
    #     `&block`.
    #   
    #   @return [nil]
    #     When something goes wrong (an error is raised).
    #   
    #   @raise
    #     If any of {DONT_RESCUE} are raised during method execution, they will
    #     be allowed to continue raising.
    #     
    #     Everything else should be rescued and reported, with `nil` being 
    #     returned.
    #     
    #     Unless something really goes wrong.
    #
    def try_critical_code *args, &block
      # Check out them args...
      
      if block.nil?
        # Can't do nothin'. Raise (which will report and return `nil`).
        raise ::ArgumentError, "No block given"
      end
      
      print_backtrace = true
      get_message = nil
      
      begin
        case args.length
        when 0
          # Pass, use the defaults
        when 1
          if args[ 0 ].is_a?( ::Hash )
            if args[ 0 ].key?( :print_backtrace )
              print_backtrace = !!args[ 0 ][ :print_backtrace ]
            end
            
            if args[ 0 ].key?( :get_message )
              if  args[ 0 ][ :get_message ].respond_to?( :call ) &&
                  args[ 0 ][ :get_message ].respond_to?( :arity )
                get_message = args[ 0 ][ :get_message ]
              else
                raise ::ArgumentError,
                  "Expected `get_message:` keyword arg to respond to `#call` " +
                  "and `#arity`; given: #{ args[ 0 ][ :get_message ].inspect }"
              end
            end
          else
            raise ::ArgumentError,
              "Expected options {Hash}, given #{ args[ 0 ].class }: " +
              args[ 0 ].inspect
          end
        else
          # Too many args... raise to warn below (and use defaults)
          raise ::ArgumentError,
            "Too many arguments. Expected 1, got #{ args.length }: " +
            args.inspect
        end
      rescue ::ArgumentError => argument_error
        # Warn that the user got the args wrong
        warn_of_critical_code_error \
          error: argument_error,
          print_backtrace: print_backtrace
      end
      
      begin
        block.call
      rescue *DONT_RESCUE
        raise
      rescue ::Exception => error
        message = "An error was raised in critical code"
        
        unless get_message.nil?
          begin
            message = if get_message.arity == 0
              get_message.call
            else
              get_message.call error
            end
          rescue *DONT_RESCUE
            raise
          rescue ::Exception => get_message_error
            warn_of_critical_code_error "`#call` to `get_message:` failed",
              error: get_message_error,
              print_backtrace: print_backtrace
          end
        end
        
        warn_of_critical_code_error *message,
          error: error,
          print_backtrace: print_backtrace
        
        return nil
      end
    rescue *DONT_RESCUE
      raise
    rescue ::Exception => really_bad
      warn_of_critical_code_error error: really_bad
    end # #try_critical_code
    
  public # end protected ***************************************************
  
end # module CriticalCode


# /Namespace
# =======================================================================

end # module  Support
end # module  NRSER