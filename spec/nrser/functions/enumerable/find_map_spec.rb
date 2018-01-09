describe_spec_file(
  spec_path: __FILE__,
  module: NRSER,
  method: :find_map,
) do
  
  describe "when a result is found" do
    it "should return the block result" do
      expect(
        subject.call( [1, 2, 3, 4] ) do |i|
          if i.even?
            "#{ i } is even!"
          end
        end
      ).to eq "2 is even!"
    end
  end
  
  
  describe "when block returns `false`" do
    it "should not be considered 'found'" do
      expect(
        subject.call( [1, 2, 3] ) { |i| false }
      ).to be nil
    end
  end
  
  
  describe "when none found and `ifnone` provided" do
    it "should call `ifnone` and return the response" do
      expect(
        subject.call( [], ->(){ 'blah' } ) { |i| false }
      ).to eq 'blah'
    end
  end # "when none found and `ifnone` provided"
  
  
end
