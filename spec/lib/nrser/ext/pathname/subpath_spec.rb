require 'nrser/ext/pathname/subpath'

SPEC_FILE(
  spec_path:        __FILE__,
  module:            NRSER::Ext::Pathname,
  instance_method:  :subpath?,
) do
  
  SETUP "Pathname.new( args[0] ).n_x.subpath? args[1]" do
    subject do
      ->( path_1, path_2 ) do
          Pathname.new( path_1 ).n_x.subpath? path_2 end end
    
    it_behaves_like "a function",
      mapping: {
        [ NRSER::ROOT, './tmp' ] => true
      }
  
  end # SETUP
  
end # SPEC_FILE