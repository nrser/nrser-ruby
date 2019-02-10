RSpec Integration for {NRSER::Described}
==============================================================================

Interface for using {NRSER::Described} from [RSpec][].


A Bit of Historical Context
------------------------------------------------------------------------------

{NRSER::Described} evolved from my old `NRSER::RSpec` module (pre `v0.4`).

After building *Described* out targeting [Cucumber][]
({NRSER::Described::Cucumber}), I wanted to unify everything on it. This module
is a port of the onld `RSpec` code, as well as a clean-up.

Generally, I want to move away from RSpec and toward Cucumber, but it's likely
RSpec will always have it's place / keep it's hold.

[Cucumber]: https://cucumber.io/
[RSpec]: http://rspec.info/
