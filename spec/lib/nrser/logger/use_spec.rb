require 'spec_helper'

describe 'NRSER::Logger.use' do
  it "points to the source logger" do
    module Source
      NRSER::Logger.install self, on: true, say_hi: false
      
      module Target
        NRSER::Logger.use Source, self
      end
    end
    
    expect_to_log { Source::Target.send :info, "here" }
    expect(Source::Target.logger).to be Source.logger
  end
end