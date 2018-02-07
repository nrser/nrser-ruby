require 'logger'

require 'spec_helper'

describe 'NRSER::Logger.level_sym' do
  it "translates level syms, names and symbols" do
    LOG_LEVELS.each do |int, (sym, name)|
      expect( NRSER::Logger.level_sym sym ).to eq sym
      expect( NRSER::Logger.level_sym int ).to eq sym
      expect( NRSER::Logger.level_sym name ).to eq sym
    end
  end

  it "pukes on bad a args" do
    BAD_LOG_LEVELS.each do |arg|
      expect {
        NRSER::Logger.level_sym arg
      }.to raise_error ArgumentError
    end
  end

end
