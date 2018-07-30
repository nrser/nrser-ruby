NRSER::Types Display Table
==============================================================================

Example table of `source` code creating types to the output of the various display
methods:

1.  {NRSER::Types::Type#name}
1.  {NRSER::Types::Type#symbolic}
1.  {NRSER::Types::Type#explain}

### Verification

These values are verified in `//spec/lib/nrser/types/display_spec.rb`, so they
should remain accurate.

### Adding & Updating

**_Don't update the values here, they will get overwritten!_**

I keep the values in a Quip doc at

<https://beiarea.quip.com/iBBRAuEZyxui>

because it's just a lot easier to manage in an actual spreadsheet (generally,
there have been some weird corner cases like columns not liking the word "true"
to be spelled like anything other than "TRUE", weird Unicode whitespace that
Quip sticks in that needs to be sub'd out, etc.).

There's a script at

[//dev/packages/gems/nrser/dev/bin/pull_types_display_table.rb][pull script]

[pull script]: ../../../../dev/bin/pull_types_display_table.rb

that will pull the Quip spreadsheet contents and **overwrite** what's here. Even
though the spreadsheet is world-viewable, you still seem to nee a Quip API token
to access it via the API.

> ##### NOTE #####
> 
> The `source` column assumes you have {NRSER::Types} available as `t`, as
> 
>     require 'nrser/refinements/types'
>     using NRSER::Types
> 
> provides. Due to how refinements bind, you may need to set `t` up as a global
> in certain testing, REPL or other funky situations.

| `source`                                    | `#name`                      | `#symbolic`            | `#explain`                            |
| ------------------------------------------- | ---------------------------- | ---------------------- | ------------------------------------- |
| `t.Numeric`                                 | `Numeric`                    | `Numeric`              | `Numeric`                             |
| `t.Integer`                                 | `Integer`                    | `ℤ`                    | `Integer`                             |
| `t.PositiveInteger`                         | `PositiveInteger`            | `ℤ⁺`                   | `(Integer & Bounded<min=1>)`          |
| `t.NegativeInteger`                         | `NegativeInteger`            | `ℤ⁻`                   | `(Integer & Bounded<max=-1>)`         |
| `t.NonNegativeInteger`                      | `NonNegativeInteger`         | `ℕ⁰`                   | `(Integer & Bounded<min=0>)`          |
| `t.Boolean`                                 | `Boolean`                    | `Boolean`              | `(Is<true> \| Is<false>)`             |
| `t.Bounded( min: 1, max: 2 )`               | `Bounded<min=1, max=2>`      | `(1..2)`               | `Bounded<min=1, max=2>`               |
| `t.Bounded( min: 1 )`                       | `Bounded<min=1>`             | `(1..)`                | `Bounded<min=1>`                      |
| `t.Array`                                   | `Array`                      | `[*]`                  | `Array`                               |
| `t.Array( t.Integer )`                      | `Array<Integer>`             | `[ℤ]`                  | `Array<Integer>`                      |
| `t.Attributes(x: t.Integer, y: t.String)`   | `(#x→Integer & #y→String)`   | `(#x→ℤ & #y→String)`   | `Attributes<#x→Integer, #y→String>`   |
