require 'nrser/ext/tree/bury'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Ext::Tree::Bury,
  method:           :bury_in!,
) do
  
  it do
    expect(
      {}.tap { |hash| subject.call hash, [ :a, :b, :c ], 1 }
    ).to eq(
      { a: { b: { c: 1 } } }
    )
  end

  CASE ~%{ string key path } do
    WHEN ~%{ :parsed_key_type option omitted } do
      it "creates hashes and sets string keys" do
        expect(
          {}.tap { |hash| subject.call hash, 'a.b.c', 1 }
        ).to eq(
          { 'a' => { 'b' => { 'c' => 1 } } }
        )
      end
    end # 
  end # string key path
  
end # SPEC_FILE
