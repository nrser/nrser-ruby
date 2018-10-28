require 'nrser/ext/enumerable/find'

SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Ext::Enumerable,
  instance_method: :find_only,
) do

  subject do
    ->( enum, *args, &block ) do
      enum.n_x.find_only *args, &block
        end end
  
  it "returns the element when only one is found" do
    expect(
      subject.( [1, 2, 3] ) { |i| i == 2 }
    ).to be 2
  end
  
  it "raises TypeError when more than one element is found" do
    expect {
      subject.( [1, 2, 3] ) { |i| i >= 2 }
    }.to raise_error TypeError
  end
  
  it "raises TypeError when no elements are found" do
    expect {
      subject.( [1, 2, 3] ) { |i| false }
    }.to raise_error TypeError
  end
  
end # SPEC_FILE
