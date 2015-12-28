require 'spec_helper'

NRSER::Logger.install MAIN, on: true, say_hi: false

describe 'NRSER::Logger.send_log' do
  it "works with blocks that yield msg strings" do
    expect_to_log {
      info {
        "hey!"
      }
    }
  end
  
  it "works with blocks that yield values hashes" do
    expect_to_log {
      info {
        {x: 'ex', y: 'why?'}
      }
    }
  end
  
  it "works with blocks that yield msg and values" do
    expect_to_log {
      info {
        ["hey!", {x: 'ex', y: 'why'}]
      }
    }
  end
  
  it "doesn't evaluate blocks unless they're going to be logged" do
    evaled = false
    
    expect_to_log {
      info {
        evaled = true
      }
    }
    
    expect(evaled).to be true
    
    evaled = false
    
    logger.off {
      expect_to_not_log {
        info {
          evaled = true
        }
      }
    }
    
    expect(evaled).to be false
    
    logger.with_level :fatal do
      expect_to_not_log {
        info {
          evaled = true
        }
      }
    end
    
    expect(evaled).to be false
  end
end