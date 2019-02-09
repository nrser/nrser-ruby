# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extends {Resolvable}
require_relative "./resolvable"


# Namespace
# =======================================================================

module  NRSER
module  Described
class   SubjectFrom


# Definitions
# =======================================================================

# A {Parameter} able to resolve from the {Described::Base#error} of other
# {Described::Base} instances in the {Hierarchy} (as well as from an 
# {Exception} provided to the {Described::Base} instance at initialization).
# 
# This is simply a {Resolvable} with {Resolvable#method_name} set to `:error`.
#
# @immutable
# 
# ### *Pro Tip* ###
# 
# If you are explicitly instantiating {ErrorOf} in description class 
# definitions, you may prefer to look cool and save up to *four* characters 
# with {Parameter.[]}:
# 
# ```Ruby
# class MyErrorDescription < Described::Object
#   
#   subject_form \
#     error: Described::SubjectFrom::ErrorOf[ Described::Response ] \
#   do |error:|
#     # Do ur shit...
#   end
#   
#   # ...
#   
# end
# ````
# 
class ErrorOf < Resolvable
  
  # Create a new {ErrorOf} able to resolve from instances of `described_class`.
  # 
  # @param described_class (see Resolvable#initialize)
  # 
  def initialize described_class
    super described_class, :error
  end
  
end # class ErrorOf


# /Namespace
# =======================================================================

end # class SubjectFrom
end # module Described
end # module NRSER
