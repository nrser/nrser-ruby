require 'spec_helper'


# NRSER.looks_like_json_array?
# ========================================================================
# 
describe "NRSER.looks_like_json_array?" do
  subject { NRSER.method :looks_like_json_array? }
  
  multiline = <<-END
      
    [
      1,
      2,
      3
    ]
    
    END
  
  it_behaves_like "function",
    success: {
      ''          => false,
      '[]'        => true,
      '[1, 2, 3]' => true,
      multiline   => true,
    }
  
  
  
end # NRSER.looks_like_json_array?

# ************************************************************************
