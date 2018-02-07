describe_spec_file(
  spec_path: __FILE__,
  module: NRSER,
  method: :find_all_map,
) do
  
  describe "when results are found" do
    it "should return the block results" do
      expect(
        subject.call( [1, 2, 3, 4] ) do |i|
          if i.even?
            "#{ i } is even!"
          end
        end
      ).to eq ["2 is even!", "4 is even!"]
    end
  end
  
  
  describe "when block returns `false`" do
    it "response should be empty" do
      expect(
        subject.call( [1, 2, 3] ) { |i| false }
      ).to eq []
    end
  end
  
end
