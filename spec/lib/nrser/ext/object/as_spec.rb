require 'nrser/ext/object/as'

SPEC_FILE \
  spec_path:        __FILE__,
  module:           NRSER::Ext::Object \
do

  logger.warn "Here I am at ExampleGroup level!"
  
  INSTANCE_METHOD :as_hash do
    SETUP "bind method" do
      subject do
        unbound_method = super()

        logger.warn "In `subject` block..." do {
          blah: 'blue',
          blow: 'me',
        } end

        ->( *args, &block ) do
          unbound_method.bind( receiver ).call *args, &block
            end end

      WHEN ~%{ `receiver` is a {Hash} }, receiver: { a: 1 } do
        CALLED do it do is_expected.to be receiver
          end end end end
      
      #   expect(h.as_hash).to be h
      #   # key doesn't matter
      #   expect(h.as_hash(:x)).to be h
      # end # returns itself when self is a hash
    # end # WHEN `receiver` is a {Hash}
    
    # context "self is nil" do
    #   it "returns {}" do
    #     expect(nil.as_hash).to eq({})
    #   end # returns {}
    # end # self is nil
    
    # context "self responds to #to_h" do
      
    #   context "#to_h succeeds" do
    #     it "returns result of #to_h" do
    #       expect([[:a, 1], [:b, 2]].as_hash).to eq({a: 1, b: 2})
    #     end # returns result of #to_h
    #   end # #to_h succeeds
      
    #   context "#to_h fails" do
    #     it "returns hash with self keyed as `key`" do
    #       expect([1, 2, 3].as_hash(:a)).to eq({a: [1, 2, 3]})
    #     end # returns hash with self keyed as `key`
        
    #     context "no key provided" do
    #       it "raises ArgumentError" do
    #         expect { [1, 2, 3].as_hash }.to raise_error ArgumentError
    #       end # raises ArgumentErrpr
    #     end # no key provided
    #     it "raises ArgumentError" do
          
    #     end # raises ArgumentErrpr
    #   end # #to_h failsexpect { [1, 2, 3].as_hash }.to raise_error ArgumentError
      
    # end # self responds to #to_h
    
  end # #as_hash
  
  
  # describe '#as_array' do
  #   context "self is nil" do
  #     it "returns {}" do
  #       expect(nil.as_array).to eq([])
  #     end # returns {}
  #   end # self is nil
    
  # end # #as_array
  
  
end # SPEC_FILE
