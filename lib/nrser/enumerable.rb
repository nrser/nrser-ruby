require 'pp'

require_relative './errors'

module NRSER
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    # Maps an enumerable object to a *new* hash with the same keys and values 
    # obtained by calling `block` with the current key and value.
    # 
    # If `enumerable` *does not* respond to `#to_pairs` then it's 
    # treated as a hash where the elements iterated by `#each` are it's keys
    # and all it's values are `nil`.
    # 
    # In this way, {NRSER.map_values} handles Hash, Array, Set, OpenStruct,
    # and probably pretty much anything else reasonable you may throw at it.
    # 
    # @param [#each_pair, #each] enumerable
    # 
    # @yieldparam [Object] key
    #   The key that will be used for whatever value the block returns in the
    #   new hash.
    # 
    # @yieldparam [nil, Object] value
    #   If `enumerable` responds to `#each_pair`, the second parameter it yielded
    #   along with `key`. Otherwise `nil`.
    # 
    # @yieldreturn [Object]
    #   Value for the new hash.
    # 
    # @return [Hash]
    # 
    # @raise [TypeError]
    #   If `enumerable` does not respond to `#each_pair` or `#each`.
    # 
    def map_values enumerable, &block
      result = {}
      
      if enumerable.respond_to? :each_pair
        enumerable.each_pair { |key, value|
          result[key] = block.call key, value
        }
      elsif enumerable.respond_to? :each
        enumerable.each { |key| 
          result[key] = block.call key, nil
        }
      else
        raise TypeError.new NRSER.squish <<-END
          First argument must respond to #each_pair or #each
          (found #{ enumerable.inspect })
        END
      end
      
      result
    end # #map_values
    
    
    
    # Find all entries in an {Enumerable} for which `&block` returns a truthy
    # value, then check the amount of results found against the
    # {NRSER::Types.length} created from `bounds`, raising a {TypeError} if 
    # the results' length doesn't satisfy the bounds type.
    # 
    # @param [Enumerable] enum
    #   The entries to search and check.
    # 
    # @param []
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    # @raise 
    # 
    def find_bounded enum, bounds, &block
      NRSER::Types.
        length(bounds).
        check(enum.find_all &block) { |type:, value:|
          NRSER.dedent <<-END
            
            Length of found elements (#{ value.length }) FAILED to 
            satisfy #{ type.to_s }
            
            Found:
              #{ NRSER.indent value.pretty_inspect }
            
            Enumerable:
              #{ NRSER.indent enum.pretty_inspect }
            
          END
        }
    end # #find_bounded
    
    
    # @todo Document find_only method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def find_only enum, &block
      find_bounded(enum, 1, &block).first
    end # #find_only
    
    
    # Return the only entry if the enumerable has `#count` one. Otherwise,
    # return `default` (which defaults to `nil`).
    # 
    # @param [Enumerable] enum
    #   Enumerable in question.
    # 
    # @param [Object] default:
    #   Value to return if `enum` does not have only one entry.
    # 
    # @return [Object]
    #   The only entry in `enum` if it has only one, else `default`.
    # 
    def only enum, default: nil
      if enum.count == 1
        enum.first
      else
        default
      end
    end
    
    
    # @todo Document only method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def only! enum
      unless enum.count == 1
        raise TypeError.new squish <<-END
          Expected enumerable #{ enum.inspect } to have exactly one entry.
        END
      end
      
      enum.first
    end # #only
    
    
    
    # @todo Document to_h_by method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def to_h_by enum, &block
      {}.tap { |result|
        enum.each { |element|
          key = block.call element
          
          if result.key? key
            raise NRSER::ConflictError.new NRSER.dedent <<-END
              Key #{ key.inspect } is already in results with value:
              
              #{ result[key].pretty_inspect }
            END
          end
          
          result[key] = element
        }
      }
    end # #to_h_by
    
    
    # Create an {Enumerator} that iterates over the "values" of an 
    # {Enumerable} `enum`. If `enum` responds to `#each_value` than we return
    # that. Otherwise, we return `#each_entry`.
    # 
    # @param [Enumerable] enum
    # 
    # @return [Enumerator]
    # 
    # @raise [TypeError]
    #   If `enum` doesn't respond to `#each_value` or `#each_entry`.
    # 
    def enumerate_as_values enum
      # NRSER.match enum,
      #   t.respond_to(:each_value), :each_value.to_proc,
      #   t.respond_to(:each_entry), :each_entry.to_proc
      # 
      if enum.respond_to? :each_value
        enum.each_value
      elsif enum.respond_to? :each_entry
        enum.each_entry
      else
        raise TypeError.squished <<-END
          Expected `enum` arg to respond to :each_value or :each_entry,
          found #{ enum.inspect }
        END
      end
    end # #enumerate_as_values
    
    
    # Count entries in an {Enumerable} by the value returned when they are 
    # passed to the block.
    # 
    # @example Count array entries by class
    #   
    #   [1, 2, :three, 'four', 5, :six].count_by &:class
    #   # => {Fixnum=>3, Symbol=>2, String=>1}
    # 
    # @param [Enumerable<E>] enum
    #   {Enumerable} (or other object with compatible `#each_with_object` and 
    #   `#to_enum` methods) you want to count.
    # 
    # @param [Proc<(E)=>C>] &block
    #   Block mapping entries in `enum` to the group to count them in.
    # 
    # @return [Hash{C=>Integer}]
    #   Hash mapping groups to positive integer counts.
    # 
    def count_by enum, &block
      enum.each_with_object( Hash.new 0 ) do |entry, hash|
        hash[block.call entry] += 1
      end
    end
    
    
    # Like `Enumerable#find`, but wraps each call to `&block` in a
    # `begin` / `rescue`, returning the result of the first call that doesn't
    # raise an error.
    # 
    # If no calls succeed, raises a {NRSER::MultipleErrors} containing the 
    # errors from the block calls.
    # 
    # @param [Enumerable<E>] enum
    #   Values to call `&block` with.
    # 
    # @param [Proc<E=>V>] &block
    #   Block to call, which is expected to raise an error if it fails.
    # 
    # @return [V]
    #   Result of first call to `&block` that doesn't raise.
    # 
    # @raise [ArgumentError]
    #   If `enum` was empty (`enum#each` never yielded).
    # 
    # @raise [NRSER::MultipleErrors]
    #   If all calls to `&block` failed.
    # 
    def try_find enum, &block
      errors = []
      
      enum.each do |*args|
        begin
          result = block.call *args
        rescue Exception => error
          errors << error
        else
          return result
        end
      end
      
      if errors.empty?
        raise ArgumentError,
          "Appears that enumerable was empty: #{ enum.inspect }"
      else
        raise NRSER::MultipleErrors.new errors
      end
    end
    
    
    # TODO It would be nice for this to work...
    # 
    # def to_enum object, meth, *args
    #   unless object.respond_to?( meth )
    #     object = NRSER::Enumerable.new object
    #   end
    # 
    #   object.to_enum meth, *args
    # end
    
    
  end # class << self (Eigenclass)
end # module NRSER
