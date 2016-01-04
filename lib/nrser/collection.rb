module NRSER
  # include this module in any custom classes to have them treated as
  # collections instead of individual objects by the methods in this file
  module Collection
    
    # [Array<Class>] stdlib classes that are considered collections.
    STDLIB = [
      Array,
      Hash,
      Set,
    ]
  end
  
  class << self
    
    # test if an object is considered a collection.
    # 
    # @param obj [Object] object to test
    # @return [Boolean] true if `obj` is a collection.
    # 
    def collection? obj
      Collection::STDLIB.any? {|cls| obj.is_a? cls} || obj.is_a?(Collection)
    end
    
    # yield on each element of a collection or on the object itself if it's
    # not a collection. avoids having to normalize to an array to iterate over
    # something that may be an object OR a collection of objects.
    # 
    # @param obj [Object] target object.
    # 
    # @yield each element of a collection or the target object itself.
    # 
    # @return [Object] obj param.
    # 
    def each obj, &block
      if collection? obj
        obj.each &block
      else
        block.call obj
        obj
      end
    end
    
    # if `obj` is a collection, calls `#map` with the block. otherwise,
    # applies block to the object and returns the result.
    # 
    # @param obj [Object] target object.
    # 
    # @yield each element of a collection or the target object itself.
    # 
    # @return [Object] the result of mapping or applying the block.
    # 
    def map obj, &block
      if collection? obj
        obj.map &block
      else
        block.call obj
      end
    end
  end
end