require 'nrser/ext/enumerable/associate'

SPEC_FILE(
  spec_path: __FILE__,
  module: Enumerable,
  instance_method: :assoc_by,
) do
    
  describe "when map does not result in duplicate keys" do
    it "should succeed" do
      expect(
        %w{a b c}.n_x.assoc_by &:ord
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
        [1, 2, 3].n_x.assoc_by { |i| i % 2 }
      }.to raise_error NRSER::ConflictError
    end
  end # Duplicate keys
  
end # SPEC_FILE
