# Definitions
# =======================================================================

module NRSER

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
      select { |klass| klass == String || klass == Symbol }.
      uniq
    
    return name_types[0] if name_types.length == 1
    
    # There are both string and symbol keys present, we can't guess
    nil
  end # .guess_label_key_type

end # module NRSER
