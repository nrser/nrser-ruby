require 'spec_helper'

describe "NRSER::Types.length" do
  subject { NRSER::Types.method :length }
  
  context "zero length" do
    kwds = {
      accepts: [ '', [], {}, ],
      rejects: [ 'x', [1], {x: 1} ],
    }
    
    # Three ways to cut it:
    it_behaves_like 'Type maker method', args: [ length: 0 ], **kwds
    it_behaves_like 'Type maker method', args: [ 0 ], **kwds
    it_behaves_like 'Type maker method', args: [ min: 0, max: 0], **kwds
      
  end # zero length
  
  it_behaves_like 'Type maker method',
    args:     [ {min: 3, max: 5}, name: '3to5Type' ],
    
    accepts: [
      [1, 2, 3],
      [1, 2, 3, 4],
      [1, 2, 3, 4, 5],
    ],
    
    rejects: [
      [1, 2],
      [1, 2, 3, 4, 5, 6]
    ],
    
    and_is_expected: {
      to: {
        have_attributes: {
          name: '3to5Type',
        }
      }
    }
    
end # NRSER::Types.length
