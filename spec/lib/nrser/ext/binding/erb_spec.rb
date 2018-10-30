require 'nrser/ext/binding'

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
    ).to eq NRSER.dedent <<-BLOCK
      x is 1
    BLOCK
  end

  it "handles edge cases" do
    expect( binding.n_x.erb ''     ).to eq ''
    expect( binding.n_x.erb 'blah' ).to eq 'blah'
  end
  
end # SPEC_FILE
