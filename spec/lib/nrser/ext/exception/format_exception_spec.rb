require 'nrser/ext/exception'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Ext::Exception,
  instance_method:  :format,
) do

  let(:error) {
    begin 
      raise StandardError.new "blah blah blah"
    rescue Exception => e
      e
    end
  }

  it "formats a raised error" do
    str = error.n_x.format
    expect( str ).to start_with "blah blah blah (StandardError):"
    expect( str.lines.drop(1) ).to all( start_with '  ' )
  end

end # SPEC_FILE
