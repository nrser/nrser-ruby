require 'nrser/ext/pathname'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Ext::Pathname,
  instance_method:  :sub,
) do
  
  CASE ~%{ `pattern` is a {Pathname} instance } do
  # ==========================================================================
    
    BOUND_TO Pathname.new( 'a/b/c' ) do
      CALLED_WITH Pathname.new( 'a/b' ), 'c/d' do
        it do is_expected.to eq Pathname.new( 'c/d/c' ) end end end
    
    BOUND_TO Pathname.new( 'c/c/c' ) do
      CALLED_WITH Pathname.new( 'c' ), 'a' do
        it ~%{ only subs the first 'c' } do
          is_expected.to eq Pathname.new( 'a/c/c' ) end end end
    
  end # CASE ~%{ `pattern` is a {Pathname} instance } ************************
  
end # SPEC_FILE