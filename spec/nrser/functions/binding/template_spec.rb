require 'spec_helper'

describe 'NRSER.template' do
  it "processes a simple template" do
    x = 1

    expect(
      NRSER.template binding, <<-BLOCK
        x is <%= x %>
      BLOCK
    ).to eq NRSER.dedent <<-BLOCK
      x is 1
    BLOCK
  end

  it "handles edge cases" do
    expect( NRSER.template binding, ''     ).to eq ''
    expect( NRSER.template binding, 'blah' ).to eq 'blah'
  end
end # template
