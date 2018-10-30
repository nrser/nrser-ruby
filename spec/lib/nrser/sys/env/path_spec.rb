require 'nrser/sys/env'

SPEC_FILE(
  spec_path: __FILE__,
  class: NRSER::Sys::Env::Path,
) do
  
  describe_method :from_ENV do
    it "loads from ENV['PATH']" do
      expect( subject.call :PATH ).to be_a( described_class )
    end
  end # Method :from_ENV Description
  
end # spec
