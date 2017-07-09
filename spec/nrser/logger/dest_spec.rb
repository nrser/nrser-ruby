require 'spec_helper'
require 'tempfile'

describe 'NRSER::Logger.dest=' do
  it "writes to multiple destinations" do
    files = [Tempfile.new('f1'), Tempfile.new('f2')]
    logger = NRSER::Logger.new dest: files, say_hi: false
    logger.info "hey!"
    files.each do |file|
      file.rewind
      data = YAML.load file.read
      expect(data['INFO']['msg']).to eq "hey!"
    end
  end
end