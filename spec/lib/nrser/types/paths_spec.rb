describe_spec_file(
  spec_path: __FILE__,
  source_file: 'nrser/types/paths.rb',
  module: NRSER::Types,
) do

  describe_method :dir_path do
    include_examples 'make type',
      accepts: [
        '.',
        '/',
        Pathname.getwd,
      ],
      
      rejects: [
        'README.md',
      ],
      
      to_data: {
        Pathname.getwd => Pathname.getwd.to_s,
      }
      
  end # method .dir_path
  
  
  describe_method :file_path do
    
    include_examples 'make type',
      accepts: [
        ( NRSER::ROOT / 'README.md' ),
      ],
      
      rejects: [
        '.',
        '/',
        Pathname.getwd,
      ],
      
      and_is_expected: {
        to: {
          have_attributes: {
            name: 'FilePath',
          }
        }
      }
    
    context "custom name" do
      include_examples 'make type',
        args: [ name: 'CustomType' ],
        
        accepts: [
          ( NRSER::ROOT / 'README.md' ),
        ],
        
        rejects: [
          '.',
          '/',
          Pathname.getwd,
        ],
        
        and_is_expected: {
          to: {
            have_attributes: {
              name: 'CustomType',
            }
          }
        }
    end # custom name
      
  end # method .dir_path
  
  
  describe_method :path_seg do
    include_examples 'make type',
      accepts: [
        'hey',
        'ho_let\'s goooo!'
      ],
      
      rejects: [
        'hey/ho',
      ],
      
      and_is_expected: {
        to: {
          have_attributes: {
            name: 'POSIXPathSegment',
          }
        }
      }
    
  end # method .path_seg
  
end
