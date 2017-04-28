# nogc

[![Build Status](https://travis-ci.org/atilaneves/nogc.png?branch=master)](https://travis-ci.org/atilaneves/nogc

Utilities to write `@nogc` code, including converting values to strings (`text`)
and a variant of `std.exception.enforce` that is `@nogc` but limits the type
of the exception thrown to be `NoGcException`. Examples:

```d
@nogc unittest {
    import nogc.conv: text;
    // works with basic types and user defined structs/classes
    assert(text(1, " ", "foo", " ", 2.0) == "1 foo 2.000000");
}
```

```d
@nogc unittest {
    import nogc.exception: enforce;
    import nogc.conv: text;
    const expected = 1;
    const actual = 1;
    enforce(actual == expected, text("Expected: ", expected, " but got: ", actual));
}
```
