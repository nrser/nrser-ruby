using NRSER

describe NRSER.method(:map_values) do
  
  it "handles hashes" do
    expect(
      NRSER.map_values({a: 1, b: 2}) { |k, v| v * 3 }
    ).to eq(
      {a: 3, b: 6}
    )
  end # handles hashes
  
  
  it "handles arrays" do
    expect(
      NRSER.map_values([:a, :b, :c]) { |k, v| "#{ k } is ok!" }
    ).to eq(
      {a: "a is ok!", b: "b is ok!", c: "c is ok!"}
    )
  end # handles arrays
  
  
  it "handles sets" do
    expect(
      NRSER.map_values(Set.new [:a, :b, :c]) { |k, v| "#{ k } is ok!" }
    ).to eq(
      {a: "a is ok!", b: "b is ok!", c: "c is ok!"}
    )
  end # handles sets
  
  
  it "handles OpenStruct instances" do
    expect(
      NRSER.map_values(OpenStruct.new a: 1, b: 2) { |k, v| v * 3 }
    ).to eq(
      {a: 3, b: 6}
    )
  end # handles OpenStruct instances
  
  
end # NRSER.map_values
