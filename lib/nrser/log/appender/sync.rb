# encoding: UTF-8
# frozen_string_literal: true


# Definitions
# =======================================================================

# Replacement for {SemanticLogger::Appender::Async} that implements the
# same interface but just logs synchronously in the current thread.
# 
# Basically just implements the {SemanticLogger::Appender::Async} API,
# returning mostly with fake / nonsense values, but it seems to work, and
# just let's writes go strait through to the {#appender} (which is actually
# a {SemanticLogger::Processor}).
# 
# Useful for CLI applications where you want to see output in sync with
# operations.
# 
class NRSER::Log::Appender::Sync
  
  # Mixins
  # ============================================================================
  
  # Macros for forwarding to {#appender}
  extend Forwardable
  
  
  # 
  # ============================================================================
  
  # The appender we forward to, which is a {SemanticLogger::Processor}
  # in practice, since it wouldn't make any sense to wrap a regular
  # appender in a Sync.
  # 
  # @return [SemanticLogger::Processor]
  #     
  attr_accessor :appender

  # Forward methods that can be called directly
  def_delegator :@appender, :name
  def_delegator :@appender, :should_log?
  def_delegator :@appender, :filter
  def_delegator :@appender, :host
  def_delegator :@appender, :application
  def_delegator :@appender, :level
  def_delegator :@appender, :level=
  def_delegator :@appender, :logger
  
  # Added for sync
  def_delegator :@appender, :log
  def_delegator :@appender, :on_log
  def_delegator :@appender, :flush
  def_delegator :@appender, :close
  
  
  # A fake {Queue} that just implements a {.size} method that returns `0`.
  # 
  # Sync appender doesn't need a queue, but Semantic Logger expects one, so
  # telling it the length is always zero seems to make sense.
  # 
  class FakeQueue
    # @return [0]
    #   Fake queue is always empty.
    def self.size
      0
    end
  end # class FakeQueue
  

  # Construct a sync appender.
  #
  # @param [SemanticLogger::Subscriber] appender
  #   The appender this appender will attempt to append to when there are  
  #   pending appendables to append. Apparently.
  #   
  #   Sorry, I just ended up here trying to clear out Yard warnings so I can 
  #   maybe figure out why it's all of sudden shitting the bed. Guess I needed
  #   a break.
  #   
  #   In truth I don't even think it needs to be a Subscriber, but that's 
  #   probably the easiest way to think about it.
  # 
  # @param [String] name
  #   Name to use for the log thread and the log name when logging any errors 
  #   from this appender.
  # 
  def initialize  appender:, name: appender.class.safe_name
    @appender = appender
  end
  
  # Needs to be there to support {SemanticLogger::Processor.queue_size},
  # which gets the queue and returns it's size (which will always be zero
  # for us).
  # 
  # We return {FakeQueue}, which only implements a `size` method that
  # returns zero.
  # 
  # @return [#size]
  # 
  def queue; FakeQueue; end
  
  
  # @return [-1]
  #   Nonsense value meant to indicate there is no lag check interval.
  def lag_check_interval; -1; end
  
  
  # @raise [NotImplementedError]
  #   Sync appender doesn't support setting lag check interval.
  def lag_check_interval= value
    raise NotImplementedError,
      "Can't set `lag_check_interval` on Sync appender"
  end
  
  
  # @return [-1]
  #   Nonsense value meant to indicate there is no lag threshold.
  def lag_threshold_s; -1; end
  
  
  # @raise [NotImplementedError]
  #   Sync appender doesn't support setting log threshold.
  def lag_threshold_s= value
    raise NotImplementedError,
      "Can't set `lag_threshold_s` on Sync appender"
  end
  
  
  # @return [false]
  #   Sync appender is of course not size-capped.
  def capped?; false; end

  
  # The {SemanticLogger::Appender::Async} worker thread is exposed via
  # this method, which creates it if it doesn't exist and returns it, but
  # it doesn't seem like the returned value is ever used; the method
  # call is just invoked to start the thread.
  # 
  # Hence it seems to make most sense to just return `nil` since we don't
  # have a thread, and figure out what to do if that causes errors (so far
  # it seems fine).
  #
  # @return [nil]
  # 
  def thread; end
  
  
  # @return [true]
  #   Sync appender is always active
  def active?; true; end

end # class NRSER::Log::Appender::Sync
