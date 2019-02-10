# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  Format


# Definitions
# =======================================================================

# A {List} is a just an {::Array} that represents a list of textual entries,
# and should be displayed as such (versus any old {::Array}, which are by
# default considered values).
# 
# @todo
#   I'm not sure if...
#   
#   1.  This is really the right / best way to accomplish this, but it's what's
#       here. It was hastily thrown in some point in history.
#       
#   2.  If this should be generalized as part of an `NRSER::Text` or
#       `NRSER::Doc` module for generically handling document elements (along
#       with `Table` and other crap).
# 
class List < ::Array
  def to_desc max = nil
    return '' if empty?
    max = [16, 64 / self.length].max if max.nil?
    map { |entry| NRSER::RSpec.short_s entry, max }.join ", "
  end
end


# /Namespace
# =======================================================================

end # module  Format
end # module  RSpec
end # module  Described
end # module  NRSER
