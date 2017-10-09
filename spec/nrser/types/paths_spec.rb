require 'spec_helper'

describe "NRSER::Types.dir_path" do
  subject { NRSER::Types.method :dir_path }
  
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
    
end # NRSER::Types.dir_path

describe "NRSER::Types.file_path" do
  subject { NRSER::Types.method :file_path }
  
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
  
    
end # NRSER::Types.dir_path
