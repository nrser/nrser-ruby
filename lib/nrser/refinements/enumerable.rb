# Instance methods that are mixed in to the refinements of many classes that
# include {Enumerable}, including {Array}, {Set}, {Hash} and {OpenStruct}.
# 
# All of these just proxy to a {NRSER} module (static) method, so the
# functionality can be used on older Rubies that can't refine.
# 
module NRSER::Refinements::Enumerable
  
  # See {NRSER.map_values}
  def map_values &block
    NRSER.map_values self, &block
  end
  
  
  # See {NRSER.find_bounded}
  def find_bounded bounds, &block
    NRSER.find_bounded self, bounds, &block
  end
  
  
  # See {NRSER.find_only}
  def find_only &block
    NRSER.find_only self, &block
  end
  
  
  # See {NRSER.to_h_by}
  def to_h_by &block
    NRSER.to_h_by self, &block
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
  
end # module NRSER::Refinements::Enumerable
