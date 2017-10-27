require 'cmds'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'nrser'
require 'nrser/logger'
require 'nrser/rspex'

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


shared_examples "type maker method" do |param_1|
  context "provided `name:` option" do
    let( :name ) { 'CustomTypeName' }
    subject { super().call name: name }
    
    it { is_expected.to be_a NRSER::Types::Type }
    it { is_expected.to have_attributes name: name }
  end # provided `name:` option
  
end # type maker method


shared_examples "make type" do |  args: [],
                                  accepts: [],
                                  rejects: [],
                                  to_data: {},
                                  from_s: nil,
                                  **expectations |
  context "#call #{ args.map(&:inspect).join ', ' }" do
    # Load the type into the subject by applying the parent scope subject,
    # which should be the Type maker method that we want to test, to the
    # args we received.
    subject{ super().call *args }
    
    # Expect that it's a {NRSER::Types::Type} and any other expectations that
    # may have been passed in.
    include_examples "expect subject",
      { to: { be_a: NRSER::Types::Type } },
      *expectations.values
    
    describe "#test" do
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
    end # #test
    
    # {NRSER::Types::Type#to_data} tests
    to_data.each { |value, data|
      it "dumps value #{ value.inspect } to data #{ data.inspect }" do
        expect( subject.to_data value ).to eq data
      end
    }
    
    # {NRSER::Types::Type.from_s} test
    unless from_s.nil?
      describe '#from_s' do
        
        if from_s.key? :accepts
          context "accepts" do
            from_s[:accepts].each { |s, expected|
              describe s.inspect do
                subject { super().from_s s }
                
                it { is_expected.to eq expected }
              end
            } # each
          end # accepts
        end
        
        if from_s.key? :rejects
          context "rejects" do
            from_s[:rejects].each { |s, error|
              describe s.inspect do
                it "raises an error" do
                  expect {
                    subject.from_s s
                  }.to raise_error *NRSER.as_array( error )
                end # raises an error
              end # 
            }
          end # rejects
        end
        
      end # #from_s
    end # unless from_s.nil?
    
  end # #call( ... )
end # Type maker method


