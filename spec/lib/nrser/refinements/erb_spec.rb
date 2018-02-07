require 'spec_helper'

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types

require 'nrser/meta/props'

describe 'Binding#erb' do
  it "refines NRSER.erb into Binding" do
    expect(
      binding.erb <<-BLOCK
        hey
      BLOCK
    ).to eq <<-BLOCK.dedent
        hey
      BLOCK
  end

  it "processes a simple template" do
    x = 1

    expect(
      binding.erb <<-BLOCK
        x is <%= x %>
      BLOCK
    ).to eq <<-BLOCK.dedent
      x is 1
    BLOCK
  end
  
  
  it "dedents before interpolating" do
    dump = JSON.pretty_generate(
      {
        x: 1,
      }
    )
    
    expected = <<-END
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
    
    expected = <<-END
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
    ERBSpecTester = Class.new( NRSER::Meta::Props::Base ) do
      prop :x, type: t.int, from_data: {hey: 'ho', lets: 'go!'}
    end
    
    prop = ERBSpecTester.props[:x]
    
    error = begin
      prop.value_from_data "I'M DATA!"
    rescue TypeError => e
      e
    end
    
    expect( error.message ).
      to eq <<-END
Expected `@from_data` to be Symbol, String or Proc;
found Hash.

Acceptable types:

-   Symbol or String
    -   Name of class method on the class this property is defined in
        (ERBSpecTester) to call with data to convert it to a
        property value.
        
-   Proc
    -   Procedure to call with data to convert it to a property value.

Found `@from_data`:

    {:hey=>"ho", :lets=>"go!"}
    
(type Hash)

END
    
  end
  

  it "handles edge cases" do
    expect( binding.erb '' ).to eq ''
    expect( binding.erb 'blah' ).to eq 'blah'
  end
end # Binding#erb
