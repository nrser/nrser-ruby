# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# Define a example group binding a subject.
# 
# @note Experimental - only used in Rash at the moment. I've wanted *something*
#   like this to make binding subject less noisy, but I'm not sure this is
#   exactly it yet...
# 
# @see #describe_x
# 
# @param [Object] subject
#   The value to bind as the subject. May be wrapped.
# 
# @param [Hash<Symbol, Object>] metadata
#   Optional metadata for the example group.
# 
# @param &body (see #describe_x)
# 
# @return (see #describe_x)
# 
def describe_subject subject, **metadata, &body
  describe_x \
    subject,
    type: :subject,
    metadata: metadata,
    subject_block: -> { unwrap subject, context: self },
    &body
end

# Short name
alias_method :SUBJECT, :describe_subject


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
