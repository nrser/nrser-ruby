
SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Ext::String,
  instance_method: :looks_like_json_array?,
) do

  multiline = <<-END
      
    [
      1,
      2,
      3
    ]
    
  END
  
  [
    [ '', false ],
    [ '[]', true ],
    [ '[1, 2, 3]', true ],
    [ multiline, true ],
  ].each do |string, expected|
    
    INSTANCE string do
      CALLED do it do is_expected.to be expected end end
    end
  
  end # each
  
end # SPEC_FILE
