require 'spec_helper'
require 'nrser/refinements'

using NRSER

describe 'NRSER.template' do
  it "refines tpl in object like it was defined in Kernel" do
    expect(
      tpl binding, <<-BLOCK
        hey
      BLOCK
    ).to eq <<-BLOCK.dedent
        hey
      BLOCK
  end

  it "processes a simple template" do
    x = 1

    expect(
      tpl binding, <<-BLOCK
        x is <%= x %>
      BLOCK
    ).to eq <<-BLOCK.dedent
      x is 1
    BLOCK
  end

  it "handles edge cases" do
    expect( tpl binding, ''     ).to eq ''
    expect( tpl binding, 'blah' ).to eq 'blah'
  end
end # template
