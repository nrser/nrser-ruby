CLASS NRSER::Described::Base do
  it { is_expected.to be_a ::Class }
  it { is_expected.to be ::NRSER::Described::Base }
  it { is_expected.to have_attributes name: "NRSER::Described::Base" }
  
  METHOD :error_type do
    it { is_expected.to be_a ::Method }
  end
  
end