module NRSER  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
    # Return an array given any value in the way that makes most sense:
    # 
    # 1.  If `value` is an array, return it.
    #     
    # 2.  If `value` is `nil`, return `[]`.
    #     
    # 3.  If `value` responds to `#to_a`, try calling it. If it succeeds, return
    #     that.
    #     
    # 4.  Return an array with `value` as it's only item.
    # 
    # Refinement
    # ----------
    # 
    # Added to `Object` in `nrser/refinements`.
    # 
    # @param [Object] value
    # 
    # @return [Array]
    # 
    def as_array value
      return value if value.is_a? Array
      return [] if value.nil?
      
      if value.respond_to? :to_a
        begin
          return value.to_a
        rescue
        end
      end
      
      [value]
    end # #as_array
    
    
    # Functional implementation of "rest" for arrays. Used when refining `#rest`
    # into {Array}.
    # 
    # @param [Array] array
    # 
    # @return [return_type]
    #   New array consisting of all elements after the first.
    # 
    def rest array
      array[1..-1]
    end # #rest
    
    
  end # class << self (Eigenclass)
  
end # module NRSER