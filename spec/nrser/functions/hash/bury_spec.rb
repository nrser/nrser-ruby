require 'spec_helper'

describe "NRSER.bury!" do
  subject { NRSER.method :bury! }
  
  it do    
    expect(
      {}.tap { |hash|
        subject.call( hash, [:a, :b, :c], 1 )
      }
    ).to eq(
      { a: { b: { c: 1 } } }
    )
  end
  
  context "string key path" do
    context ":parsed_key_type option omitted" do
      it "creates hashes and sets string keys" do
        expect(
          {}.tap { |hash|
            subject.call( hash, 'a.b.c', 1 )
          }
        ).to eq(
          { 'a' => { 'b' => { 'c' => 1 } } }
        )
      end
    end # :key_type option omitted

  end # string key path
  
end # NRSER.bury
