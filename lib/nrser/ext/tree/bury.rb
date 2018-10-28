# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Deps
# ------------------------------------------------------------------------

# Using {Object#deep_dup}
require 'active_support/core_ext/object/deep_dup'


# Project / Package
# ------------------------------------------------------------------------

# Using {NRSER::Types.Tree}
# require 'nrser/types/collections'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Tree

  # Class Methods
  # ========================================================================
  # 
  # Functionality is implemented as class methods, due to
  # 
  # 1.  It's history as part of `//lib/nrser/functions`.
  #     
  # 2.  It avoids potentially having to extend every tree when diving down,
  #     which should be advantageous when {Bury} has not been mixed in to the
  #     core classes themselves.
  # 

  # Guess which type of "label" key - strings or symbols - a hash (or other
  # object that responds to `#keys` and `#empty`) uses.
  # 
  # @param [#keys & #empty] keyed
  #   Hash or similar object that responds to `#keys` and `#empty` to guess
  #   about.
  # 
  # @return [nil]
  #   If we can't determine the type of "label" keys are used (there aren't
  #   any or there is a mix).
  # 
  # @return [Class]
  #   If we can determine that {String} or {Symbol} keys are exclusively
  #   used returns that class.
  # 
  def self.guess_label_key_type keyed
    # We can't tell shit if the hash is empty
    return nil if keyed.empty?
    
    name_types = keyed.
      keys.
      map( &:class ).
      select { |klass| klass == ::String || klass == ::Symbol }.
      uniq
    
    return name_types[0] if name_types.length == 1
    
    # There are both string and symbol keys present, we can't guess
    nil
  end # .guess_label_key_type


  # Recursive method that does the burying mutation.
  # 
  def self.bury_in!   tree,
                      key_path,
                      value,
                      parsed_key_type: :guess,
                      clobber: false,
                      create_arrays_for_unsigned_keys: false
    
    # Normalize key path
    case key_path
    when ::Array
      # pass
    when ::Enumerable
      key_path = key_path.to_a
    when ::String
      key_path = key_path.split '.'

      # Convert the keys to symbols now if that's what we want to use
      if parsed_key_type == Symbol
        key_path.map! &:to_sym
      end
    else
      # assume it's a single key
      key_path = [ key_path ]
    end

    # Split the key path into the current key and the rest of the keys
    key, *rest = key_path
    
    # If we are
    # 
    # -   Guessing the key type
    # -   The tree is keyed
    # -   The tree uses some {Symbol} (and no {String}) keys
    # 
    # then convert the key to a symbol.
    # 
    if  parsed_key_type == :guess &&
        tree.respond_to?( :keys ) &&
        guess_label_key_type( tree ) == Symbol
      key = key.to_sym
    end
    
    # Terminating case: we're at the last segment
    if rest.empty?
      # Set the value
      tree[key] = value
      
    else
      # Go deeper...
      
      # See if there is a hash in place
      unless NRSER::Types.tree.test tree[key]
        # There is not... so we need to do some figurin'
        
        # If we're clobbering or the hash has no value, we're good:
        # assign a new hash to set in
        if clobber || tree[key].nil?
          if  create_arrays_for_unsigned_keys &&
              NRSER::Types.unsigned.test( key )
            tree[key] = []
          else
            tree[key] = {}
          end
          
        else
          # We've got an intractable state conflict; raise
          raise NRSER::ConflictError.new \
            "can not set key", key, "due to conflicting value",
            tree[key], "in tree", tree, "(:clobber option not set)",
            tree: tree,
            key_path: key_path,
            key: key,
            value: value,
            parsed_key_type: parsed_key_type,
            clobber: clobber,
            create_arrays_for_unsigned_keys: create_arrays_for_unsigned_keys
          
        end
      end # unless hash[key].is_a?( Hash )
      
      # Dive in...
      bury_in! \
        tree[ key ],
        rest,
        value,
        parsed_key_type: parsed_key_type,
        clobber: clobber,
        create_arrays_for_unsigned_keys: create_arrays_for_unsigned_keys
      
    end # if rest.empty? / else
  end # .bury_in!
  
  
  # Instance Methods
  # ========================================================================
  # 
  # Methods to be mixed in to "tree" classes or individual instances.
  # 
  
  # Invoke {.guess_label_key_type} on `self`.
  # 
  # @return (see .guess_label_key_type)
  # 
  def guess_label_key_type
    Bury.guess_label_key_type self
  end # #guess_label_key_type


  # The opposite of `#dig` - set a value at a deep key path, creating
  # necessary structures along the way and optionally clobbering whatever is
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
  # @param [Class | :guess] parsed_key_type
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
  def bury! key_path,
            value,
            parsed_key_type: :guess,
            clobber: false,
            create_arrays_for_unsigned_keys: false
    Bury.bury_in! \
      self,
      key_path,
      value,
      parsed_key_type: parsed_key_type,
      clobber: clobber,
      create_arrays_for_unsigned_keys: create_arrays_for_unsigned_keys
  end # .bury!


  # Does a {Hash#deep_dup} then {#bury!} in order to not mutate `self`.
  # 
  # @param (see #bury!)
  # 
  # @return [Hash]
  # 
  def bury *args, &block
    deep_dup.tap do |hash|
      hash.n_x.bury! *args, &block
    end
  end


end # module Tree


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
