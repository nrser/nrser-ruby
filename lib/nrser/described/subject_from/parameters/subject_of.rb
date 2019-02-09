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

# 
# @immutable
# 
class SubjectOf < Resolvable
  def initialize described_class
    super described_class, :subject
  end
end # class SubjectOf


# /Namespace
# =======================================================================

end # class SubjectFrom
end # module Described
end # module NRSER
