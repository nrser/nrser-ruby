# encoding: UTF-8
# frozen_string_literal: true

# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Extensions to stdlib classes that are used to add additional data and methods
# to values loaded from features.
# 
# As objects get passed around through parameter types, steps, and the various
# helpers and utilities it becomes *very* useful to have context attached to 
# them, and this is how I went about it.
# 
module Wrappers

  class Block < ::Proc
  end # class Block
  
  
  module Strings
    class Src < ::String
      def block?
        start_with? '&'
      end
      
      # @return [Block]
      #   If {.block?} is `true`.
      # 
      # @return [::Object]
      #   If {.block?} is `false`.
      # 
      def to_value self_obj
        if block?
          self_obj.send :eval, "#{ Block.name }.new #{ self }"
        else
          self_obj.send :eval, self
        end
      end
    end # class Src
  end # module String
  
end # module Wrappers

# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
