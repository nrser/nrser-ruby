require 'set'
require 'ostruct'

module NRSER
  # include this module in any custom classes to have them treated as
  # collections instead of individual objects by the methods in this file
  module Collection
    
    # [Array<Class>] stdlib classes that are considered collections.
    STDLIB = [
      Array,
      Hash,
      Set,
      OpenStruct,
    ]
  end
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # test if an object is considered a collection.
    # 
    # @param obj [Object] object to test
    # @return [Boolean] true if `obj` is a collection.
    # 
    def collection? obj
      Collection::STDLIB.any? {|cls| obj.is_a? cls} || obj.is_a?(Collection)
    end
    
    
    # Yield on each element of a collection or on the object itself if it's
    # not a collection. avoids having to normalize to an array to iterate over
    # something that may be an object OR a collection of objects.
    # 
    # **NOTE**  Implemented for our idea of a collection instead of testing
    #           for response to `#each` (or similar) to avoid catching things
    #           like {IO} instances, which include {Enumerable} but are 
    #           probably not what is desired when using {NRSER.each}
    #           (more likely that you mean "I expect one or more files" than
    #           "I expect one or more strings which may be represented by
    #           lines in an open {File}").
    # 
    # @param [Object] object
    #   Target object.
    # 
    # @yield
    #   Each element of a collection or the target object itself.
    # 
    # @return [Object]
    #   `object` param.
    # 
    def each object, &block
      if collection? object
        # We need to test for response because {OpenStruct} *will* respond to
        # #each because *it will respond to anything* (which sucks), but it 
        # will return `false` for `respond_to? :each` and the like, and this
        # behavior could be shared by other collection objects, so it seems 
        # like a decent idea.
        if object.respond_to? :each_pair
          object.each_pair &block
        elsif object.respond_to? :each
          object.each &block
        else
          raise TypeError.squished <<-END
            Object #{ obj.inpsect } does not respond to #each or #each_pair
          END
        end
      else
        block.call object
      end
      object
    end
    
    
    # If `object` is a collection, calls `#map` with the block. Otherwise,
    # applies block to the object and returns the result.
    # 
    # See note in {NRSER.each} for discussion of why this tests for a
    # collection instead of duck-typing `#map`.
    # 
    # @param [Object] object
    #   Target object.
    # 
    # @yield
    #   Each element of a collection or the target object itself.
    # 
    # @return [Object]
    #   The result of mapping or applying the block.
    # 
    def map object, &block
      if collection? object
        object.map &block
      else
        block.call object
      end
    end # #map
    
  end # class << self
end # module NRSER