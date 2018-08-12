SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER,
  method:           :normalized_path?,
) do
  
  it_behaves_like "a function",
    mapping: {
      # Absolute paths
      '/' => true,
      '/x/y/z' => true,
      '/x/y/z/' => true,

      # Relative paths
      '.' => true,
      './' => true,
      './x/y/z' => true,
      './x/' => true,

      # Empty segments
      './/' => false,
      '//' => false,
      '/x//y/' => false,
      'x/y/z//' => false,

      # `..` segments
      '../x/y' => false,
      '/x/../y' => false,
      'x/y/..' => false,

      # But `...` is fine
      '/x/.../y' => true,
    }
  
end # SPEC_FILE