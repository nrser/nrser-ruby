require 'nrser/ext/tree/bury'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Ext::Tree,
  method:           :guess_label_key_type,
) do
  
  # subject { NRSER.method :guess_label_key_type }
  
  it "can't guess about an empty hash" do
    expect( subject.call( {} ) ).to be nil
  end
  
  it "guesses String when all keys are strings" do
    expect( subject.call( {'a' => 1, 'b' => 2} ) ).to be String
  end
  
  it "guesses Symbol when all keys are symbols" do
    expect( subject.call( {a: 1, b: 2} ) ).to be Symbol
  end
  
  it "guesses String when there are string keys but no symbols" do
    expect(
      subject.call({
        'a' => 1,
        [:b] => 2,
        3 => 'three',
      })
    ).to be String
  end
  
  it "guesses Symbol when there are symbol keys but no strings" do
    expect(
      subject.call({
        a: 1,
        ['b'] => 2,
        3 => 'three',
      })
    ).to be Symbol
  end
  
  it "can't guess when there are string and symbol keys" do
    expect(
      subject.call({
        a: 1,
        'b' => 2,
      })
    ).to be nil
  end
  
end # SPEC_FILE
