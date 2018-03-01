describe_spec_file(
  spec_path: __FILE__,
  module: NRSER,
  method: :find_only,
) do
  
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
  
end # spec file
