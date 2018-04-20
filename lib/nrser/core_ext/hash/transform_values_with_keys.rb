class Hash
  # Just like {Hash#transform_values} but yields `key, value`.
  # 
  def transform_values_with_keys &block
    return enum_for( __method__ ) { size } unless block_given?
    return {} if empty?
    result = self.class.new
    each do |key, value|
      result[key] = block.call key, value
    end
    result
  end
  
  
  # Just like {#transform_values_with_keys} but mutates `self`.
  # 
  def transform_values_with_keys! &block
    return enum_for( __method__ ) { size } unless block_given?
    each do |key, value|
      self[key] = block.call key, value
    end
  end
  
end
