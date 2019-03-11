# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext
module  String


# Definitions
# =======================================================================

# Regexp {NRSER.words} uses to split strings. Probably not great but it's
# what I have for the moment.
# 
# @return {Regexp}
# 
SPLIT_WORDS_RE = /[\W_\-\/]+/


# Split string into 'words' for word-based matching.
# 
# @return [Array<String>]
#   Array of non-empty words in `string`.
# 
def words
  split( Ext::String::SPLIT_WORDS_RE ).reject { |w| w.empty? }
end # .words


# /Namespace
# ========================================================================

end # module String
end # module Ext
end # module NRSER
