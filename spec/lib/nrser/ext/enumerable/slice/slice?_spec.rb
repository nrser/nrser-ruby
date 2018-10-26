require 'nrser/ext/enumerable/slice'

describe_spec_file(
  spec_path: __FILE__,
  module: NRSER::Ext::Enumerable,
  instance_method: :slice?,
) do

  subject do
    ->( enum, *args, &block ) {
      enum.n_x.slice? *args, &block
    }
  end
    
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
