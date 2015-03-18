require 'spec_helper'

require 'nrser/exec'

describe "NRSER::Exec.sub" do

  it "runs a string with spaces" do
    expect(
      NRSER::Exec.sub "echo %{msg}", msg: "hey there"
    ).to eq 'echo hey\ there'
  end

  it "runs a string with $" do
    expect(
      NRSER::Exec.sub "echo %{msg}", msg: "$HOME"
    ).to eq 'echo \$HOME'
  end

end # describe sub
