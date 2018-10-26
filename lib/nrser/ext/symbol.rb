class Symbol

  # Proxy through to built-in {#to_proc} so symbols match the {Array#to_sender}
  # API. I guess.
  # 
  # @return [Proc]
  #   Accepts one argument and sends itself to that object, returning the
  #   result.
  # 
  def to_sender; self.to_proc; end
  
end # class Symbol
