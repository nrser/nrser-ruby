require 'nrser/ext/pathname'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Ext::Pathname,
  instance_method:  :start_with?,
) do
  
  CASE ~%{ {Pathname} `prefixes` } do
  # ==========================================================================
    CLASS ::Pathname do
    
      INSTANCE_FROM 'a/b/c' do
      
        CALLED_WITH Pathname.new( 'a/b' ) do
          it do is_expected.to be true end end
        
        CALLED_WITH Pathname.new( 'a/b/' ) do
          it do is_expected.to be true end end end
      
      INSTANCE_FROM '/a/b/c' do
        CALLED_WITH Pathname.new( '/' ) do
          it do is_expected.to be true end end end
    
    end # CLASS
    
  end # CASE ~%{ `pattern` is a {Pathname} instance } ************************
  
end # SPEC_FILE