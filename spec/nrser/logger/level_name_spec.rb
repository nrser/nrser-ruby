require 'logger'

require 'spec_helper'

describe 'NRSER::Logger.level_name' do

  it "translates level names, integers and symbols" do
    LOG_LEVELS.each do |int, (sym, name)|
      expect( NRSER::Logger.level_name name ).to eq name
      expect( NRSER::Logger.level_name sym ).to eq name
      expect( NRSER::Logger.level_name int ).to eq name
    end
  end

  it "pukes on bad a args" do
    BAD_LOG_LEVELS.each do |arg|
      expect {
        NRSER::Logger.level_name arg
      }.to raise_error ArgumentError
    end
  end

end
