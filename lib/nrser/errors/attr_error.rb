# frozen_string_literal: true

# Raised when we expected `#count` to be something it's not.
# 
# Extends {NRSER::ValueError}, and the {#value} must be the instance that
# 
class NRSER::AttrError < NRSER::ValueError
  
  # Name of attribute that has invalid value.
  # 
  # @return [Symbol]
  #     
  attr_reader :symbol
  
  
  # Actual invalid value of the subject's attribute.
  # 
  # If not provided at construction, will be retrieved by sending {#symbol}
  # to {#subject} in {#initialize}.
  # 
  # @return [Object]
  #     
  attr_reader :actual
  
  
  # An optional expected value to use in {#build_message}.
  # 
  # @return [Object]
  #     
  attr_reader :expected
  
  
  # @param [Object] subject:
  #   The object that has the invalid attribute value.
  # 
  def initialize message = nil, symbol:, subject:, **options
    @symbol = symbol.to_sym
    
    @actual = if options.key?( :actual )
      options[:actual]
    else
      value.send @symbol
    end
    
    @has_expected = options.key? :expected
    @expected = options[:expected]
    
    super message, subject: subject
  end
  
  def has_expected?
    @has_expected
  end
  
  def build_message
    headline = if has_expected?
      "#{ subject.class } object has invalid ##{ symbol }: " +
        "expected #{ expected }, found #{ actual }"
    else
      "#{ subject.class } object has invalid ##{ symbol } (found #{ actual })"
    end
    
    binding.erb <<-END
      <%= headline  %>
      
      Subject:
      
          <%= subject.pretty_inspect %>
      
    END
  end
  
end # class NRSER::CountError
