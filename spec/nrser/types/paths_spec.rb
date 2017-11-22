require 'spec_helper'

describe_file 'types/paths.rb' do

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
  
  
  describe 'NRSER::Types::POSIX_PATH_SEGMENT_RE' do
    subject { NRSER::Types::POSIX_PATH_SEGMENT_RE }
    
    describe_method 'match' do
      subject { super().method :match }
      
      it_behaves_like "function",
        mapping: {
          ["hey"] =>  wrap { be_a( MatchData ) },
          ["h/ey"] => nil,
        }
      
    end # Method match Description
    
    
  end # NRSER::Types::POSIX_PATH_SEGMENT_RE
  
  
end