require_relative './enumerable'

module NRSER
  refine ::Array do
    include NRSER::Refinements::Enumerable
    
    
    # @return [Array]
    #   new array consisting of all elements after the first (which may be 
    #   none, resulting in an empty array).
    # 
    def rest
      NRSER.rest self
    end # #rest
    
    
    # Returns a lambda that calls accepts a single arg and calls `#dig` on it
    # with the elements of *this* array as arguments.
    # 
    # @example
    #   list = [{id: 1, name: "Neil"}, {id: 2, name: "Mica"}]
    #   list.to_h_by &[:id].digger
    #   # =>  {
    #   #       1 => {id: 1, name: "Neil"},
    #   #       2 => {id: 2, name: "Mica"},
    #   #     }
    # 
    # @todo
    #   I wanted to use `#to_proc` so that you could use `&[:id]`, but unary
    #   `&` doesn't invoke refinements, and I don't really want to monkey-patch
    #   anything, especially something as core as `#to_proc` and `Array`.
    # 
    # @return [Proc]
    #   Lambda proc that accepts a single argument and calls `#dig` with this 
    #   array's contents as the `#dig` arguments.
    # 
    def digger
      ->(digable) {
        digable.dig *self
      }
    end # #digable
    
    
    # Checks that length is 2 and returns `self`.
    # 
    # @return [Array]
    #   Array of length 2.
    # 
    # @raise [TypeError]
    #   If length is not 2.
    # 
    def to_pair
      unless length == 2
        raise TypeError,
              "Array is not of length 2: #{ self.inspect }"
      end
      
      self
    end # #to_pair
    
    
  end # refine ::Array
end # NRSER