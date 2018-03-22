
class Object
  # Yield `self`. Analogous to {#tap} but returns the result of the invoked
  # block.
  def thru
    yield self
  end
  
  
  # See {NRSER.truthy?}.
  def truthy?
    NRSER.truthy? self
  end
  
  
  # See {NRSER.falsy?}.
  def falsy?
    NRSER.falsy? self
  end
  
  
  # Calls {NRSER.as_hash} on `self` with the provided `key`.
  def as_hash key = nil
    NRSER.as_hash self, key
  end
  
  
  # Call {NRSER.as_array} on `self`.
  def as_array
    NRSER.as_array self
  end
  
end # class Object