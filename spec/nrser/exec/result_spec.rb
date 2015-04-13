require 'shellwords'

require 'spec_helper'

require 'nrser/exec'

describe "NRSER::Exec.result" do
  context "successful command" do
    msg = "hey!"

    let(:result) {
      NRSER::Exec.result "echo %{msg}", msg: msg
    }

    it "should have exitstatus 0" do
      expect( result.exitstatus ).to eq 0
    end

    it "should return true for #success?" do
      expect( result.success? ).to be true
    end

    it "should return false for #failure?" do
      expect( result.failure? ).to be false
    end

    it "should not raise an error on #check_error" do
      expect{ result.check_error }.not_to raise_error
    end

    it "should raise Errno::NOERROR on #raise_error" do
      expect{ result.raise_error }.to raise_error Errno::NOERROR
    end

    it "should have output 'hey!\\n'" do
      expect( result.output ).to eq "hey!\n"
    end

    it %{should have cmd "echo #{ Shellwords.escape(msg) }"} do
      expect( result.cmd ).to eq "echo #{ Shellwords.escape(msg) }"
    end
  end

  context "failed command" do
    let(:result) {
      NRSER::Exec.result "false"
    }

    it "should not have exitstatus 0" do
      expect( result.exitstatus ).not_to eq 0
    end

    it "should return false for #success?" do
      expect( result.success? ).to be false
    end

    it "should return true for #failure?" do
      expect( result.failure? ).to be true
    end

    it "should raise an error on #check_error" do
      expect{ result.check_error }.to raise_error Errno::EPERM
    end

    it "should raise Errno::EPERM on #raise_error" do
      expect{ result.raise_error }.to raise_error Errno::EPERM
    end

    it "should have output ''" do
      expect( result.output ).to eq ""
    end

    it "should have cmd 'false'" do
      expect( result.cmd ).to eq "false"
    end
  end
end # describe result