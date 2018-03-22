describe_spec_file(
  spec_path: __FILE__,
  module: NRSER,
  method: :assoc_by,
) do
    
  describe "when map does not result in duplicate keys" do
    it "should succeed" do
      expect(
        subject.call %w{a b c}, &:ord
      ).to eq({
        97 => 'a',
        98 => 'b',
        99 => 'c',
      })
    end
  end #
  
  
  describe "when map results in duplicate keys" do
    it "should raise NRSER::ConflictError" do
      expect {
        subject.call( [1, 2, 3] ) { |i| i % 2 }
      }.to raise_error NRSER::ConflictError
    end
  end # Duplicate keys
  
end # spec file
