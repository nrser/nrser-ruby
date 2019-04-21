Lazy Resolution in {NRSER::Described}
==============================================================================

*Lazy resolution* defers resolving described subjects until an expectation is
made. It can be enabled with the `@lazy` tag.

This lets you describe things out-of-order, like describing a call in the 
background section of a feature and describing different parameters to it in 
each scenario.

This can be pretty useful, and is reasonably easy to get right in simple
situations where you are constructing an object or making a call and examining
the results, but it can quickly become confusing and error-prone when multiple
objects are interacting and resolution order and side effects are important.
It is also a behavior most features and scenarios just don't need.

It used to be the default and only resolution mode, but after running into 
the afore-mentioned difficulties, I've moved it to being behind a tag.
