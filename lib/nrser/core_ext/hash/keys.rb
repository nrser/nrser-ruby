require 'active_support/core_ext/hash/keys'

##############################################################################
# Short Names for Active Support's {Hash} "Keys" Extensions
# ============================================================================
# 
# Implemented as a strait core ext because it depends on Active Support's
# `hash/keys` extension, so why even bother with a ext module.
# 
##############################################################################

class Hash
  # NOTE  If we use `alias_method` here it breaks subclasses that override
  #       `#symbolize_keys`, etc. - like {HashWithIndifferentAccess}
  # 

  def sym_keys! *args, &block;  symbolize_keys! *args, &block;  end
  def sym_keys  *args, &block;  symbolize_keys  *args, &block;  end
  
  def str_keys! *args, &block;  stringify_keys! *args, &block;  end
  def str_keys  *args, &block;  stringify_keys  *args, &block;  end
  
  def to_options! *args, &block;  symbolize_keys! *args, &block;  end
  def to_options  *args, &block;  symbolize_keys  *args, &block;  end
  
end
