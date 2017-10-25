module NRSER
  
  def self.leaves hash, path: [], results: {}
    hash.each { |key, value|
      new_path = [*path, key]
      
      case value
      when ::Hash
        leaves value, path: new_path, results: results
      else
        results[new_path] = value
      end
    }
    
    results
  end # .leaves
  
end # module NRSER
