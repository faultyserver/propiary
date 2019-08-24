# Propiary

> It's like topiary, but actually not at all.

Automatically generate a list of instance variable declarations as a constant in your types for use in `macro finished`.

**NOTE:** This currently doesn't really work. It can handle basic `property`, and `getter` calls, but anything that implies nilability will have awkward interactions.


## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     propiary:
       github: faultyserver/propiary
   ```

2. Run `shards install`


## Usage

```crystal
require "propiary"

# That's really it!
```

By default, there's nothing to change in your code! This library just replaces the standard `property` macros on `Object` with new versions. Just make sure `propiary` is one of the first things you include in your project!

These new versions will automatically generate a list of variable declarations as they are defined on the class, and that constant will be accessible in `macro finished`, and at any point during runtime.

The constant is called `Prop_Types` (a la React's PropTypes) and can be used like so:

```crystal
require "propiary"

struct Post
  property title : String
  property posted_at : Time

  macro finished
    {% for prop in Prop_Types %}
      {% puts "#{prop.name} is a `#{prop.type}`" %}
    {% end %}
  end
end


# This code outputs
#     title is a `String`
#     posted_at is a `Time`
```

Why does the casing of `Prop_Types` look weird? Specifically to avoid potential naming conflicts with any types you may be defining in your code!


## Caveats

This list is of _known_ caveats with this library. There may be more that come up with usage of this library. Please file an issue if you an encounter any issues not listed here. Most likely, bugs will be added as new caveats, rather than attempting to work around them. This is to minimize the different between the macros defined here and the standard library.

- Only properties defined with `TypeDeclaration` nodes can be interpreted and added to the list of constants. This is because at the point of invocation, the macro can't infer the type of the variable. Some `Assign` nodes may be supported in the future

- Type declarations should cover all possible types for a variable. This should be implicitly ensured by the first caveat, but if the

- Inherited properties will not be included in the generated `Prop_Types` list. This can be manually solved by iterating known ancestors in your macro, but otherwise there is no (currently known) way to directly access those variables.


## Motivation

Propiary is a library specifically created as a "standardized" workaround to some caveats of `macro finished` in Crystal. Namely that `@type.instance_vars` is not available outside of method definitions.

There are plenty of libraries out there that have a DSL of macros for generating fields, and these DSLs often have one thing in common: they store defined instance variables in a list to be able to use them in `macro finished` to generate new types based on those properties. This is especially common in ORMs libraries, configuration libraries, and others. In almost every case, these macros do a bit of work, store off the property type into a list, and then call `property {{field}}` or similar.

Why do they store off that list of fields? Because otherwise it is not possible to access those instance variables from macros outside of method definitions. As an example where this issue doesn't occur, look at `JSON::Serializable` from the standard library. This works because the accesses to `@type.instance_vars` are _within_ method definitions that are created by `macro finished`, which is supported by the language.

Outside of method definitions, `instance_vars` will _always_ return an empty list, meaning it is impossible to use that list to generate new properties, create derived types, or anything other than writing method implementations.

However, constants are available _anywhere_ in macros, and using `macro finished` ensures that all instance variable declarations have been seen before being called, so the list is guaranteed to be populated before being run in the macro, and then users can do whatever they want with those definitions.

The problem with the DSL approach is that it is non-composable. If one library requires a DSL to store off types for it to use, and then another library needs the same, there is no way to compose them together without writing a library compatibility layer, or duplicating code, and even then it may not/likely won't work as expected.

This can already been seen with something like the `DB.mapping` or (now defunct) `JSON.mapping` macros in the standard library. Before `JSON::Serializable` was added and annotations were supported, classes would have to write the same property definitions and pass them to these macros individually. ORM libraries and others often does this inside their own DSLs to avoid _obvious_ repetition, but in practice it is still there. And those libraries have to _explicitly_ and _knowingly_ define `DB.mapping` and such for this to work.

Now image a new library or integration system comes along that has it's own `.mapping` macro. Should all of these existing ORMs and libraries update their DSLs to generate that macro as well? Should users be left to duplicate their properties into that macro? Neither seems beneficial.

Annotations have helped limit this dependency, as most libraries only generate new methods instead of derived types, where `@type.instance_vars` is available and the entire issue is avoided. But while annotations are extremely powerful, they do not address this issue at its heart.

**This library exists to mitigate this dependency problem.** By creating a single list of properties through the standardized `property` macros, the coupling of DSLs and property definitions can be removed, and libraries can become more composable as a result.

By using the standard `property` macros in their DSLs, other libraries automatically opt-in to this behavior when used in a project that includes this library, and new libraries can be sure that they have access to all instance variables defined by a class, regardless of any other DSLs or libraries that may be used.

My personal motivation for creating this library and dealing with this issue as a whole comes from my library [`change`](https://github.com/faultyserver/change), an implementation of Ecto's Changesets in Crystal. I wanted to write a data validation and manipulation library that can be added to any Object in Crystal (and used with any ORM or other library) with a type-aware, type-safe, heap-less `struct` on top of the underlying Object, and ran into this issue (among others) when trying to generate that derived `struct`.

**NOTE:** The behavior of `macro finished` has already been documented/discussed on the language via multiple GitHub issues:

- https://github.com/crystal-lang/crystal/issues/6021
- https://github.com/crystal-lang/crystal/issues/6028
- https://github.com/crystal-lang/crystal/issues/7504
- probably others

Without more viable use cases for having instance variables outside of method definitions created in the `finished` macro, it is understandably not worth changing due to added complexity and potential tradeoffs. _Please do not create new issues about this feature in the language because of this repository_.


## Development

I don't expect much development here since this is meant to be a drop-in replacement for the standard library's `property` macros. But, if so, just use the standard issue->fork->pr workflow :)
