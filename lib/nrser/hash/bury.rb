# Definitions
# =======================================================================

module NRSER
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # The opposite of `#dig` - set a value at a deep key path, creating 
    # necessary structures along the way and optionally clobbering whatever's
    # in the way to achieve success.
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
        if guess_key_type && guess_label_key_type( hash ) == Symbol
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