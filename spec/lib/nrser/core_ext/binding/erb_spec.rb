require 'nrser/core_ext/binding'

describe 'Binding#erb' do
  it "processes a simple template" do
    x = 1

    expect(
      binding.erb <<-BLOCK
        x is <%= x %>
      BLOCK
    ).to eq NRSER.dedent <<-BLOCK
      x is 1
    BLOCK
  end

  it "handles edge cases" do
    expect( binding.erb ''     ).to eq ''
    expect( binding.erb 'blah' ).to eq 'blah'
  end
end # template
