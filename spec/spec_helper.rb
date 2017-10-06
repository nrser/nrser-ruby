require 'cmds'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'nrser'
require 'nrser/logger'
require 'nrser/spex'

MAIN = self

LOG_LEVELS = {
  Logger::DEBUG => [:debug, 'DEBUG'],
  Logger::INFO => [:info, 'INFO'],
  Logger::WARN => [:warn, 'WARN'],
  Logger::ERROR => [:error, 'ERROR'],
  Logger::FATAL => [:fatal, 'FATAL'],
  Logger::UNKNOWN => [:unknown, 'UNKNOWN'],
}

BAD_LOG_LEVELS = [:blah, -1, 6, "BLAH"]

def expect_to_log &block
  expect(&block).to output.to_stderr_from_any_process
end

def expect_to_not_log &block
  expect(&block).to_not output.to_stderr_from_any_process
end


shared_examples "Type maker method" do |  args: [],
                                          accepts: [],
                                          rejects: [],
                                          to_data: {},
                                          **expectations |
  context "#call( #{ args.map(&:inspect).join ', ' } )" do
    # Load the type into the subject by applying the parent scope subject,
    # which should be the Type maker method that we want to test, to the
    # args we received.
    refine_subject :call, *args
    
    # Expect that it's a {NRSER::Types::Type} and any other expectations that
    # may have been passed in.
    include_examples "expect subject",
      { to: { be_a: NRSER::Types::Type } },
      *expectations.values
    
    # Make sure it accepts the accepts
    accepts.each { |value|
      it "accepts #{ value.inspect }" do
        expect( subject.test value ).to be true
      end
    }
    
    # And that it rejects the rejects
    rejects.each { |value|
      it "rejects #{ value.inspect }" do
        expect( subject.test value ).to be false
      end
    }
    
    # {NRSER::Types::Type#to_data} tests
    to_data.each { |value, data|
      it "dumps value #{ value.inspect } to data #{ data.inspect }" do
        expect( subject.to_data value ).to eq data
      end
    }
  end
end # Type maker method


