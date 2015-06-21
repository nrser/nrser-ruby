require 'spec_helper'
require 'nrser/refinements'

using NRSER

describe "NRSER.format_exception" do
  let(:error) {
    begin 
      raise StandardError.new "blah blah blah"
    rescue Exception => e
      e
    end
  }

  it "refines Exception" do
    str = error.format
    expect( str ).to start_with "blah blah blah (StandardError):"
    expect( str.lines.drop(1) ).to all( start_with '  ' )
  end
end