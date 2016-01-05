require 'spec_helper'

using NRSER

describe 'NRSER::Logger#die' do
  it "prints the log message when logger is off" do
    src = <<-END.dedent
      require 'nrser/logger'
    
      NRSER::Logger.install self
      
      die "die!", cause: "just 'cause"
    END
    
    err = Cmds.err("bundle exec ruby"){ src }
    data = YAML.load(err)['FATAL']
    
    expect(data['msg']).to eq 'die!'
    expect(data['values']).to eq({'cause' => "just 'cause"})
  end
  
  it(
    "prints only to the log when it's on and the log writes to " + 
    "$stderr"
  ) do
    src = <<-END
      require 'nrser/logger'
      
      NRSER::Logger.install self, on: true, say_hi: false
      
      die "die!", cause: "just 'cause"
    END
    
    err = Cmds.err("bundle exec ruby"){ src }
    
    data = YAML.load(err)['FATAL']
    
    expect(data['msg']).to eq 'die!'
    expect(data['values']).to eq({'cause' => "just 'cause"})
  end
end