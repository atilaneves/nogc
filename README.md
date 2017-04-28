# nogc

[![Build Status](https://travis-ci.org/atilaneves/nogc.png?branch=master)](https://travis-ci.org/atilaneves/nogc

Utilities to write `@nogc` code, including converting values to strings (`text`)
and a variant of `std.exception.enforce` that is `@nogc` but limits the type
of the exception thrown to be `NoGcException`. Examples:

```d
// text is @system because it returns a slice to a static array
// if you need to store the string you'll need to make a copy
// since consecutive calls will return the same slice and it will
// be mutated
@nogc @system unittest {
    import nogc.conv: text;
    // works with basic types and user defined structs/classes
    assert(text(1, " ", "foo", " ", 2.0) == "1 foo 2.000000");
}


// enforce is @safe, since it internally makes a call to `text` but
// immediately throws an exception, and casting it to `string` makes
// it immutable. Ugly but it works.
@nogc @safe unittest {
    import nogc.exception: enforce;
    import nogc.conv: text;
    const expected = 1;
    const actual = 1;
    enforce(actual == expected, "Expected: ", expected, " but got: ", actual);
}
```
