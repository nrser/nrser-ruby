# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

### Project / Package ###

# Using {Ext::Elidable#ellipsis}
require 'nrser/ext/elidable'


# Namespace
# ========================================================================

module  NRSER
module  Ext
module  String

# Definitions
# =======================================================================

# Compact repeated blank lines to a single one.
# 
# @param [Boolean] remove_leading
#   
# 
# @return [::String]
# 
def compact_blank_lines remove_leading: false
  out = []
  skipping = remove_leading
  lines.each do |line|
    if line =~ /^\s*$/
      unless skipping
        out << line
      end
      skipping = true
    else
      skipping = false
      out << line
    end
  end
  out.join
end # .compact_blank_lines


# /Namespace
# ========================================================================

end # module String
end # module Ext
end # module NRSER
