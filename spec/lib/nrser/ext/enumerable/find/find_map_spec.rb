require 'nrser/ext/enumerable/find'

SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Ext::Enumerable,
  instance_method: :find_map,
) do

  # TODO  Shim to adapt how spec was originally written
  subject do
    ->( receiver, *args, &block ) {
      receiver.n_x.find_map *args, &block
    }
  end
  
  describe "when a result is found" do
    it "should return the block result" do
      expect(
        [1, 2, 3, 4].find_map do |i|
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
        [1, 2, 3].find_map { |i| false }
      ).to be nil
    end
  end
  
  
  describe "when none found and `ifnone` provided" do
    it "should call `ifnone` and return the response" do
      expect(
        [].find_map( -> { 'blah' } ) { |i| false }
      ).to eq 'blah'
    end
  end # "when none found and `ifnone` provided"
  
  
end # SPEC_FILE
