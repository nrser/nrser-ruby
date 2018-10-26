class OpenStruct
  # See {NRSER.to_open_struct}.
  def self.from_h hash, freeze: false
    NRSER.to_open_struct hash, freeze: freeze
  end # .from
end # class OpenStruct
