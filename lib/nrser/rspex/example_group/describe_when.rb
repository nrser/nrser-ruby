# encoding: UTF-8
# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # Define a example group with the keyword args as bindings.
  # 
  # @see #describe_x
  # 
  # @param *description (see #describe_x)
  # 
  # @param [Hash<Symbol, Object>] bindings
  #   See the `bindings` keyword arg in {#describe_x}.
  # 
  # @param &body (see #describe_x)
  # 
  # @return (see #describe_x)
  # 
  def describe_when *description, it:, **bindings, &body

    if it
      raise "Don't it and body bro" if body

      body = -> {
        self.it { is_expected.to }
      }
    end

    describe_x \
      *description,
      type: :when,
      bindings: bindings,
      &body
  end
  
  # Old name (used to be different method)
  alias_method :context_where, :describe_when

  # Short names (need `_` pre 'cause of `when` Ruby keyword, and suffix fucks
  # up auto-indent in Atom/VSCode)
  alias_method :_when, :describe_when
  
  
end # module NRSER::RSpex::ExampleGroup
