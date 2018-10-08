require 'nrser/functions/enumerable/associate'
require_relative './enumerable/find_map'
require_relative './enumerable/slash_map'


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

  
  # Right now, *exactly* the same as {#find_only}... though I wished I had
  # called it this and had {#find_only} return `nil` if it failed, as is 
  # kind-of a some-what established practice, because now I get confused.
  # 
  # Maybe some day I will make that change. For now, this is here so when I
  # forget and add the `!` it works.
  # 
  def find_only! &block
    NRSER.find_only self, &block
  end
  
  
  # See {NRSER.assoc_by}
  def assoc_by *args, &block
    NRSER.assoc_by self, *args, &block
  end
  
  
  # See {NRSER.assoc_to}
  def assoc_to *args, &block
    NRSER.assoc_to self, *args, &block
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
  
  
  # See {NRSER.slice?}
  def slice? *args, &block
    NRSER.slice? self, *args, &block
  end
  
end # module Enumerable
