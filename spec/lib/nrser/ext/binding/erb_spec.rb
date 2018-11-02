require 'nrser/ext/binding'
require 'nrser/props'
require 'nrser/props/immutable/hash_variable'

require 'nrser/refinements/types'
using NRSER::Types

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Ext::Binding,
  instance_method:  :erb,
) do
  
  it "processes a simple template" do
    x = 1

    expect(
      binding.n_x.erb <<-BLOCK
        x is <%= x %>
      BLOCK
    ).to eq <<~BLOCK
      x is 1
    BLOCK
  end
  
  
  it "handles edge cases" do
    expect( binding.n_x.erb ''     ).to eq ''
    expect( binding.n_x.erb 'blah' ).to eq 'blah'
  end
  
  
  it "dedents before interpolating" do
    dump = JSON.pretty_generate(
      {
        x: 1,
      }
    )
    
    expected = <<~END
      dump is:
      
      {
        "x": 1
      }
      
    END

    expect(
      binding.erb <<-END
       dump is:
       
       <%= dump %>
       
      END
    ).to eq expected
  end
  
  
  it "preserves indent" do
    dump = JSON.pretty_generate(
      {
        x: 1,
      }
    )
    
    expected = <<~END
      dump is:
      
          {
            "x": 1
          }
      
    END
    
    expect(
      binding.erb %{
        dump is:
        
            <%= dump %>
        
      }
    ).to eq expected
  end
  
  
  it "works on a real-world example" do
    ERBSpecTester = Class.new do
      include NRSER::Props::Immutable::HashVariable
      
      prop :x, type: t.int, from_data: {hey: 'ho', lets: 'go!'}
    end
    
    prop = ERBSpecTester.props[:x]
    
    error = begin
      prop.value_from_data "I'M DATA!"
    rescue TypeError => e
      e
    end
    
    expect( error.message ).
      to eq <<~END
        Expected `@from_data` to be Symbol, String or Proc found Hash
        
        # Details
        
        Acceptable types:
        
        -   Symbol or String
            -   Name of class method on the class this property is defined in
                (`@defined_in`) to call with data to convert it to a
                property value.
                
        -   Proc
            -   Procedure to call with data to convert it to a property value.
        
        
        # Context
        
        @from_data: {:hey=>"ho", :lets=>"go!"}
        
        @defined_in: ERBSpecTester
        
      END
    
  end
  
end # SPEC_FILE
