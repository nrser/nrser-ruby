require 'spec_helper'

require 'nrser/exec'

describe "NRSER::Exec.run" do
  
  it "subs a string with spaces" do
    expect(
      NRSER::Exec.run "echo %{msg}", msg: "hey there"
    ).to eq "hey there\n"
  end

  it "subs a string with $" do
    expect(
      NRSER::Exec.run "echo %{msg}", msg: "$HOME"
    ).to eq "$HOME\n"
  end

  it "handles commands that error" do
    expect{ NRSER::Exec.run "false" }.to raise_error SystemCallError
  end

end # describe run