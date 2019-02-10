# frozen_string_literal: true
# encoding: utf-8


# Namespace
# ========================================================================

module  NRSER
module  Described
module  RSpec
module  ExampleGroup


# Definitions
# =======================================================================

# HACK HACK HACK-ITY HACK - Allow for overriding RSpec methods
# 
# Yeah, it has to do with mixin mixing-in ordering - seems to be that when
# 
#     config.extend NRSER::RSpec::ExampleGroup
# 
# {NRSER::RSpec::ExampleGroup} gets mixed in *very early* in the chain,
# before {RSpec::Core::ExampleGroup}... why you would provide an explicit
# extension mechanism and not give those extensions priority I'm not sure,
# but I'm sure I shouldn't be looking into it right now, so here we are:
# 
# It turns out that {NRSER::RSpec::Example}, which gets mixed with
# 
#     config.include NRSER::RSpec::Example
# 
# gets mixed *last*, so by using it's {NRSER::RSpec::Example.included}
# hook we can use
# 
#   base#extend NRSER::RSpec::ExampleGroup::Overrides
# 
# to mix these guys over the top of RSpec's methods.
# 
# Seems like we could just mix all of {NRSER::RSpec::ExampleGroup} there
# to get the behavior I would have expected all along, but maybe it's better
# to have these explicit notes for the moment and not change much else until
# I get the chance to really check out what's going on.
# 
# And really it's all to override `.described_class` to pick up our
# metadata if it's there, but that approach is in quite a bit of use at
# this point, and, no, I have no idea how it seemed to work up until this
# point :/
# 
module Overrides
  
  # Override {RSpec::Core::ExampleGroup.described_class} to use RSpec's
  # `:class` metadata if it's present.
  # 
  # Because I can't figure out how to feed RSpec the described class
  # without it being the description, and we want better descriptions.
  # 
  # Some hackery could def do it, this is RUBY after all, but whatever this
  # works for now and may even be less fragile.
  # 
  # @return [Class]
  #   If there's a `:class` in the metadata, or if RSpec has on through the
  #   standard means (`describe MyClass do ...`).
  # 
  # @return [nil]
  #   If we don't have a class context around.
  # 
  def described_class
    metadata[:class] || super()
  end


  def described_module
    metadata[:module] || described_class
  end
  
end # module Overrides


# /Namespace
# ========================================================================

end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module  NRSER
