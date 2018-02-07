describe_spec_file(
  spec_path: __FILE__,
  module: NRSER,
  method: :slice?,
) do
    
  it_behaves_like "function",
    mapping: {
      [ [1, 2, 3], [] ] => true,
      [ [1, 2, 3], [1] ] => true,
      [ [1, 2, 3], [1, 2] ] => true,
      [ [1, 2, 3], [1, 2, 3] ] => true,
      [ [1, 2, 3], [2] ] => true,
      [ [1, 2, 3], [2, 3] ] => true,
      [ [1, 2, 3], [3] ] => true,
      [ [1, 2, 1, 2, 3], [1, 2, 3] ] => true,
      
      [ [1, 2, 3], [1, 3] ] => false,
      [ [1, 2, 3], [1, 2, 3, 4] ] => false,
      
      [ [1, 2, 3], [4] ] => false,
      [ [1, 2, 3], [4, 5] ] => false,
      
      # Doesn't work for now...
      # [(1..5), (2..3)] => true,
    }
  
end # spec file
