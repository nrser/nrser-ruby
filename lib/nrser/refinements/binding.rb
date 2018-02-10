module NRSER
  # Harness to include {NRSER::Ext::Binding} in {Binding}
  refine Binding do
    include NRSER::Ext::Binding
  end
end # NRSER
