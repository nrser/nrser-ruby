Cucumber Integration for {NRSER::Described}
==============================================================================

This is what {NRSER::Described} was developed for (though it's root lay in an
extension for [RSpec][]).

This module is fairly complex. It has many small classes, the majority of which
exist to package *what* a value is and what you can *do* with it along with the
primary data.

This is meant to make the module reasonably easy to use and extend: at any point
that you have an object, you should be able to figure out what it means and do
what you want with it without having to trace implicit meaning through where
it's been and how it managed to show up there.

[Cucumber]: https://cucumber.io/
[RSpec]: http://rspec.info/
