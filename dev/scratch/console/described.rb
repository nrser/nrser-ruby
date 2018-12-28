require 'nrser/meta/names'

Names = NRSER::Meta::Names

require 'nrser/described/cucumber/parameter_types'

ParameterTypes = NRSER::Described::Cucumber::ParameterTypes


def lca *classes
  classes.
    map( &:ancestors ).
    select { |mod| mod.is_a? ::Class }.
    map( &:to_set ).
    reduce( :& ).
    min
end