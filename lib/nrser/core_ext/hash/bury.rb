require 'active_support/core_ext/object/deep_dup'

class Hash

  # See {NRSER.bury!}
  def bury! key_path,
            value,
            parsed_key_type: :guess,
            clobber: false
    NRSER.bury! self,
                key_path,
                value,
                parsed_key_type: parsed_key_type,
                clobber: clobber
  end
  
  def bury *args, &block
    deep_dup.tap { |hash| hash.bury! *args, &block }
  end
end
