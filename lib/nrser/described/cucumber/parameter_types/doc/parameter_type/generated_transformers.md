Generated Transformers for Tokens in Parameter Types
==============================================================================

Constructing Parameter Types with {::Symbol} Transformers
------------------------------------------------------------------------------

When a {::Symbol} is provided for the `transformer:` keyword argument in
{NRSER::Described::Cucumber::ParameterTypes::ParameterType#initialize}, it is
interpreted as the **name of an instance method** on matched
{NRSER::Described::Cucumber::Tokens::Token} to call.


Built-In Usage
------------------------------------------------------------------------------

`:unquote` and `:to_value` are commonly used to denote the
{NRSER::Described::Cucumber::Tokens::Token#unquote} and
{NRSER::Described::Cucumber::Tokens::Token#to_value} methods, respectively, and
should work on all token instances.

At the time of writing (2018.12.29), {NRSER::Described::Cucumber::Tokens::Const}
also supports two additional symbols: `:to_class` and `:to_module`, pointing to
{NRSER::Described::Cucumber::Tokens::Const#to_class} and
{NRSER::Described::Cucumber::Tokens::Const#to_module}, to resolve instances of
that token class to {:Class} and {::Module} instances, respectively.

They are used in the
{NRSER::Described::Cucumber::ParameterTypes::Consts::CLASS} and
{NRSER::Described::Cucumber::ParameterTypes::Consts::MODULE} parameter type
definitions.


Custom Token Transformers
------------------------------------------------------------------------------

If you are defining your own {NRSER::Described::Cucumber::Tokens::Token}
subclasses, you may want to implement support for additional custom
transformations, which will allow you to use their name symbols in
{NRSER::Described::Cucumber::ParameterTypes::ParameterType} definitions, as well
as wherever you have an instance and want to transform it.

### Required Support

For a transformation named `<NAME>` on your token subclass `<TOKEN>`, you
**MUST** define a `<TOKEN>#<NAME>` instance method.

It's signature **MUST** be **EXACTLY ONE** of:

1.  `<TOKEN>#<NAME>()`
    
    With no parameters (arity `0`), this signature denotes that the
    transformation is independent of the scenario instance environment, as
    it will be called with no parameters and will not have anything except
    it's own instance data and generally accessible objects to use.
    
    If you don't need access to the scenario instance, please use this form
    to make that clear.
    
    Example:
    
    ```ruby
    class MyToken < NRSER::Described::Cucumber::Tokens::Token
      def to_custom
        # Do something to `self` to produce the value...
      end
    end
    ```
    
2.  `<TOKEN>#<NAME>(::Object)`
    
    With a single required positional parameter (arity `1`), the scenario
    object (confusingly called `self_obj` in Cucumber's parameter type code,
    and mine at the moment as well) will be provided.

    This is how {NRSER::Described::Cucumber::Tokens::Const#to_value} is able
    to resolve a constant name from {NRSER::Described::Cucumber}'s dynamic
    scenario scope modules: by calling
    {NRSER::Described::Cucumber::World::Scope#resolve_const} on the scenario
    object (which mixes {NRSER::Described::Cucumber::World::Scope} in along
    with the rest of {NRSER::Described::Cucumber::World}).
    
    Example:
    
    ```ruby
    class MyToken < NRSER::Described::Cucumber::Tokens::Token
      def to_custom scenario_obj
        # Do something using `self` and access to `scenario_obj`
      end
    end
    ```

### Optional Support for Automatic `type:` Resolution

**IF** you want to use automatic type resolution (allowing you to omit the
`type:` keyword at parameter type definition when using the new transformer
symbol), **THEN** you **MUST** define a `<TOKEN>.<NAME>_type` singleton method.

It will be called with no parameters, and it **MUST** return a {::Class} that
all return values from `<TOKEN>#<NAME>` will be instances of (even if that's
just {::Object}).

Example:

```ruby
class Custom
  def self.from_s string
    # Instantiate from a string...
  end
end

class MyToken < NRSER::Described::Cucumber::Tokens::Token
  def to_custom
    Custom.from_s self
  end
  
  def self.to_custom_type
    Custom
  end
end
```

### What's Up My Sleave?

All the fanciness is confined to
{NRSER::Described::Cucumber::ParameterTypes::ParameterType}. Nothing tricky
happens in token classes.

{NRSER::Described::Cucumber::ParameterTypes::ParameterType} a bit of a monster,
but it's monstrosity allows token classes to be simple and parameter type
definitions to be clean and concise, the idea being that you or I will want to
add new token and parameter types far more than we'll want to extend 
{NRSER::Described::Cucumber::ParameterTypes::ParameterType}.

### Further Reading

To understand tokens, as well as the {NRSER::Meta::Names} classes that you'll
see around, check out {NRSER::Strings::Patterned}, which is the base class for
all of those.

{NRSER::Regexps::Composed} is also used quote a bit as the workhorse for
composing reasonable {::Regexp} into the hideous horrors needed to match some
of the parameter types.

And, of course, if you really want to see how the sausage is made,
{NRSER::Described::Cucumber::ParameterTypes::ParameterType}.
