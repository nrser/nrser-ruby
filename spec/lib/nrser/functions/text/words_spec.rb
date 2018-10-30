SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER,
  method: :words,
) do
  it_behaves_like "function",
    mapping: {
      'some-words' => ['some', 'words'],
      'NRSER' => ['NRSER'],
      'NRSER::Text' => ['NRSER', 'Text'],
      
      # Doesn't de-camel
      'NRSER::RSpex' => ['NRSER', 'RSpex'],
      
      
    }
end
