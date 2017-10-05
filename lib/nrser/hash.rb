module NRSER
  
  def self.leaves hash, path: [], results: {}
    hash.each { |key, value|
      new_path = [*path, key]
      
      case value
      when Hash
        leaves value, path: new_path, results: results
      else
        results[new_path] = value
      end
    }
    
    results
  end # .leaves
  
  
  # Treat the value as the value for `key` in a hash if it's not already a
  # hash and can't be converted to one:
  # 
  # 1.  If the value is a `Hash`, return it.
  #     
  # 2.  If `value` is `nil`, return `{}`.
  #     
  # 3.  If the value responds to `#to_h` and `#to_h` succeeds, return the
  #     resulting hash.
  #     
  # 4.  Otherwise, return a new hash where `key` points to the value.
  #     **`key` MUST be provided in this case.**
  # 
  # Useful in method overloading and similar situations where you expect a 
  # hash that may specify a host of options, but want to allow the method
  # to be called with a single value that corresponds to a default key in that
  # option hash.
  # 
  # Refinement
  # ----------
  # 
  # Added to `Object` in `nrser/refinements`.
  # 
  # 
  # Example Time!
  # -------------
  # 
  # Say you have a method `m` that handles a hash of HTML options that can
  # look something like
  # 
  #     {class: 'address', data: {confirm: 'Really?'}}
  # 
  # And can call `m` like
  # 
  #     m({class: 'address', data: {confirm: 'Really?'}})
  # 
  # but often you are just dealing with the `:class` option. You can use
  # {NRSER.as_hash} to accept a string and treat it as the `:class` key:
  # 
  #     using NRSER
  #     
  #     def m opts
  #       opts = opts.as_hash :class
  #       # ...
  #     end
  # 
  # If you pass a hash, everything works normally, but if you pass a string
  # `'address'` it will be converted to `{class: 'address'}`.
  # 
  # 
  # About `#to_h` Support
  # ---------------------
  # 
  # Right now, {.as_hash} also tests if `value` responds to `#to_h`, and will
  # try to call it, using the result if it doesn't raise. This lets it deal 
  # with Ruby's "I used to be a Hash until someone mapped me" values like
  # `[[:class, 'address']]`. I'm not sure if this is the best approach, but 
  # I'm going to try it for now and see how it pans out in actual usage.
  # 
  # @todo
  #   It might be nice to have a `check` option that ensures the resulting
  #   hash has a value for `key`.
  # 
  # @param [Object] value
  #   The value that we want to be a hash.
  # 
  # @param [Object] key [default nil]
  #   The key that `value` will be stored under in the result if `value` is 
  #   not a hash or can't be turned into one via `#to_h`. If this happens
  #   this value can **NOT** be `nil` or an `ArgumentError` is raised.
  # 
  # @return [Hash]
  # 
  # @raise [ArgumentError]
  #   If it comes to constructing a new Hash with `value` as a value and no
  #   argument was provided 
  # 
  def self.as_hash value, key = nil
    return value if value.is_a? Hash
    return {} if value.nil?
    
    if value.respond_to? :to_h
      begin
        return value.to_h
      rescue
      end
    end
    
    # at this point we need a key argument
    if key.nil?
      raise ArgumentError,
            "Need key to construct hash with value #{ value.inspect }, " +
            "found nil."
    end
    
    {key => value}
  end # .as_hash
  
  
  
  # Lifted from ActiveSupport
  # =====================================================================
  # 
  # Not sure *why* I didn't want to depend on ActiveSupport in the first place,
  # but I'm guessing it's many other things depending on it and the potential
  # for dependency hell, but anyways, I didn't, and I'm going to keep it that
  # way for the moment.
  # 
  # However, I do want some of that functionality, and I think it makes sense
  # to keep the names and behaviors the same since ActiveSupport is so wide
  # spread.
  # 
  # The methods are modified to operate functionally since we use refinements
  # instead of global monkey-patching, and Ruby versions before 2.1 (I think)
  # don't support refinements, so these are useful in environments where you
  # don't want to mess with the global built-ins and you don't have 
  # refinements available.
  # 
  
  # Removes the given keys from hash and returns it.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:except!
  # 
  # @param [Hash] hash
  #   Hash to mutate.
  # 
  # @return [Hash]
  # 
  def self.except_keys! hash, *keys
    keys.each { |key| hash.delete(key) }
    hash
  end
  
  singleton_class.send :alias_method, :omit_keys!, :except_keys!
  
  
  # Returns a new hash without `keys`.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:except
  # 
  # @param [Hash] hash
  #   Source hash.
  # 
  # @return [Hash]
  # 
  def self.except_keys hash, *keys
    except_keys! hash.dup, *keys
  end
  
  singleton_class.send :alias_method, :omit_keys, :except_keys
  
  
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:transform_keys!
  # 
  # @param [Hash] hash
  #   Hash to mutate keys.
  # 
  # @return [Hash]
  #   The mutated hash.
  # 
  def self.transform_keys! hash
    # File 'lib/active_support/core_ext/hash/keys.rb', line 23
    hash.keys.each do |key|
      hash[yield(key)] = hash.delete(key)
    end
    hash
  end
  
  
  # Returns a new hash with each key transformed by the provided block.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:transform_keys
  # 
  # @param [Hash] hash
  # 
  # @return [Hash]
  #   New hash with transformed keys.
  # 
  def self.transform_keys hash, &block
    # File 'lib/active_support/core_ext/hash/keys.rb', line 12
    result = {}
    hash.each_key do |key|
      result[yield(key)] = hash[key]
    end
    result
  end
  
  # My-style name
  singleton_class.send :alias_method, :map_keys, :transform_keys
  
  
  # Mutates `hash` by converting all keys that respond to `#to_sym` to symbols.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:symbolize_keys!
  # 
  # @param [Hash] hash
  # 
  # @return [Hash]
  # 
  def self.symbolize_keys! hash
    transform_keys!(hash) { |key| key.to_sym rescue key }
  end # .symbolize_keys!
  
  
  # Returns a new hash with all keys that respond to `#to_sym` converted to
  # symbols.
  # 
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:symbolize_keys
  # 
  # @param [Hash] hash
  # 
  # @return [Hash]
  # 
  def self.symbolize_keys hash
    # File 'lib/active_support/core_ext/hash/keys.rb', line 54
    transform_keys(hash) { |key| key.to_sym rescue key }
  end
  
  
  # Converts all keys into strings by calling `#to_s` on them. **Mutates the
  # hash.**
  # 
  # Lifted from ActiveSupport.
  # 
  # @param [Hash] hash
  # 
  # @return [Hash<String, *>]
  # 
  def self.stringify_keys! hash
    transform_keys! hash, &:to_s
  end
  
  
  # Returns a new hash with all keys transformed to strings by calling `#to_s`
  # on them.
  # 
  # Lifted from ActiveSupport.
  # 
  # @param [Hash] hash
  # 
  # @return [Hash<String, *>]
  # 
  def self.stringify_keys hash
    transform_keys hash, &:to_s
  end
  
  
  # Lifted from ActiveSupport.
  # 
  # @see http://www.rubydoc.info/gems/activesupport/5.1.3/Hash:slice
  # 
  # 
  def self.slice_keys hash, *keys
    # We're not using this, but, whatever, leave it in...
    if hash.respond_to?(:convert_key, true)
      keys.map! { |key| hash.send :convert_key, key }
    end
    
    keys.each_with_object(hash.class.new) { |k, new_hash|
      new_hash[k] = hash[k] if hash.has_key?(k)
    }
  end
  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    
    
    # @todo Document select_map method.
    # 
    # @param [type] arg_name
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def select_map arg_name
      # method body...
    end # #select_map
    
    
    # Guess which type of "name" key - strings or symbols - a hash (or other 
    # object that responds to `#keys` and `#empty`) uses.
    # 
    # @param [#keys & #empty] keyed
    #   Hash or similar object that responds to `#keys` and `#empty` to guess
    #   about.
    # 
    # @return [nil]
    #   If we can't determine the type of name keys used.
    # 
    # @return [Class]
    #   If we can determine that {String} or {Symbol} keys are exclusively
    #   used returns that class.
    # 
    def guess_name_type keyed
      # We can't tell shit if the hash is empty
      return nil if keyed.empty?
      
      name_types = keyed.
        keys.
        map( &:class ).
        select { |klass| klass == String || klass == Symbol }.
        uniq
      
      return name_types[0] if name_types.length == 1
      
      # There are both string and symbol keys present, we can't guess
      nil
    end # #guess_key_type
    
    
    # @todo Document bury method.
    # 
    # @param [Hash] hash
    #   Hash to bury the value in.
    # 
    # @param [Array | #to_s] key_path
    #   -   When an {Array}, each entry is used exactly as-is for each key.
    #       
    #   -   Otherwise, the `key_path` is converted to a string and split by
    #       `.` to produce the key array, and the actual keys used depend on 
    #       the `parsed_key_type` option.
    # 
    # @param [Object] value
    #   The value to set at the end of the path.
    # 
    # @param [Class | :guess] parsed_key_type:
    #   How to handle parsed key path segments:
    #   
    #   -   `String` - use the strings that naturally split from a parsed
    #       key path.
    #       
    #       Note that this is the *String class itself, **not** a value that 
    #       is a String*.
    #       
    #   -   `Symbol` - convert the strings that are split from the key path
    #       to symbols.
    #       
    #       Note that this is the *Symbol class itself, **not** a value that
    #       is a Symbol*.``
    #       
    #   -   `:guess` (default) - 
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def bury! hash,
              key_path,
              value,
              parsed_key_type: :guess,
              clobber: false
      
      # Parse the key if it's not an array
      unless key_path.is_a?( Array )
        key_path = key_path.to_s.split '.'
        
        # Convert the keys to symbols now if that's what we want to use
        if parsed_key_type == Symbol
          key_path.map! &:to_sym
        end
      end
      
      _internal_bury! \
        hash,
        key_path,
        value,
        guess_key_type: ( parsed_key_type == :guess ),
        clobber: clobber
    end # #bury
    
    
    
    private
    # ========================================================================
      
      
      # @todo Document _internal_bury! method.
      # 
      # @param [type] arg_name
      #   @todo Add name param description.
      # 
      # @return [return_type]
      #   @todo Document return value.
      # 
      def _internal_bury! hash,
                          key_path,
                          value,
                          guess_key_type:,
                          clobber:
                          
        # Split the key path into the current key and the rest of the keys
        key, *rest = key_path
        
        # If we are guessing the key type and the hash uses some {Symbol}
        # (and no {String}) keys then convert the key to a symbol.
        if guess_key_type && guess_name_type( hash ) == Symbol
          key = key.to_sym
        end
        
        # Terminating case: we're at the last segment
        if rest.empty?
          # Set the value
          hash[key] = value
          
        else
          # Go deeper...
          
          # See if there is a hash in place
          unless hash[key].is_a?( Hash )
            # There is not... so we need to do some figurin'
            
            # If we're clobbering or the hash has no value, we're good:
            # assign a new hash to set in
            if clobber || ! hash.key?( key )
              hash[key] = {}
              
            else
              # We've got an intractable state conflict; raise
              raise NRSER::ConflictError.new squish <<-END
                can not set key #{ key.inspect } due to conflicting value
                #{ hash[key].inspect } in hash #{ hash.inspect } (:clobber
                option not set)
              END
              
            end
          end # unless hash[key].is_a?( Hash )
          
          # Dive in...
          bury! hash[key], rest, value
          
        end # if rest.empty? / else
      end # #_internal_bury!
      
      
    # end private
    
    
    
  end # class << self (Eigenclass)
  
  
end # module NRSER