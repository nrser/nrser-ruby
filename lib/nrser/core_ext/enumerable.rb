# Instance methods to extend {Enumerable}.
# 
module Enumerable
  
  # See {NRSER.find_bounded}
  def find_bounded bounds, &block
    NRSER.find_bounded self, bounds, &block
  end
  
  
  # See {NRSER.find_only}
  def find_only &block
    NRSER.find_only self, &block
  end
  
  
  # See {NRSER.assoc_by}
  def assoc_by &block
    NRSER.assoc_by self, &block
  end
  
  
  # See {NRSER.assoc_to}
  def assoc_to &block
    NRSER.assoc_to  self, &block
  end
  
  
  # See {NRSER.enumerate_as_values}
  def enumerate_as_values
    NRSER.enumerate_as_values self
  end
  
  
  # Calls {NRSER.only} on `self`.
  def only **options
    NRSER.only self, **options
  end
  
  
  # See {NRSER.only!}
  def only!
    NRSER.only! self
  end
  
  
  # See {NRSER.count_by}
  def count_by &block
    NRSER.count_by self, &block
  end
  
  
  # See {NRSER.try_find}
  def try_find &block
    NRSER.try_find self, &block
  end
  
  
  # See {NRSER.find_map}
  def find_map *args, &block
    NRSER.find_map self, *args, &block
  end
  
  # See {NRSER.slice?}
  def slice? *args, &block
    NRSER.slice? self, *args, &block
  end
  
  
end # module Enumerable