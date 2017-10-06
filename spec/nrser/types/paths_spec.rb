require 'spec_helper'

describe "NRSER::Types.dir_path" do
  subject { NRSER::Types.method :dir_path }
  
  it_behaves_like 'Type maker method',
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
    
end # NRSER::Types.dir_path

describe "NRSER::Types.file_path" do
  subject { NRSER::Types.method :file_path }
  
  it_behaves_like 'Type maker method',
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
    it_behaves_like 'Type maker method',
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
  
    
end # NRSER::Types.dir_path
