require 'spec_helper'
require 'nrser/refinements'

using NRSER

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

  it "handles edge cases" do
    expect( binding.erb '' ).to eq ''
    expect( binding.erb 'blah' ).to eq 'blah'
  end
end # Binding#erb
