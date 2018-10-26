module NRSER
  
  # @!group Enumerable Functions
  
  # Test if an object is "array-like" - is it an Enumerable and does it respond
  # to `#each_index`?
  # 
  # @param [Object] object
  #   Any old thing.
  # 
  # @return [Boolean]
  #   `true` if `object` is "array-like" for our purposes.
  # 
  def self.array_like? object
    object.is_a?( ::Enumerable ) &&
      object.respond_to?( :each_index )
  end # .array_like?
  
  
  # Test if an object is "hash-like" - is it an Enumerable and does it respond
  # to `#each_pair`?
  # 
  # @param [Object] object
  #   Any old thing.
  # 
  # @return [Boolean]
  #   `true` if `object` is "hash-like" for our purposes.
  # 
  def self.hash_like? object
    object.is_a?( ::Enumerable ) &&
      object.respond_to?( :each_pair )
  end # .hash_like?
  
  
  # TODO It would be nice for this to work...
  # 
  # def to_enum object, meth, *args
  #   unless object.respond_to?( meth )
  #     object = NRSER::Enumerable.new object
  #   end
  # 
  #   object.to_enum meth, *args
  # end
  
end # module NRSER
