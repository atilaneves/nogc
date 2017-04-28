module nogc;

public import nogc.conv;
public import nogc.exception;

version(unitThreadedLight):

@nogc unittest {
    import nogc.conv: text;
    // works with basic types and user defined structs/classes
    assert(text(1, " ", "foo", " ", 2.0) == "1 foo 2.000000");
}


@nogc unittest {
    import nogc.exception: enforce;
    import nogc.conv: text;
    const expected = 1;
    const actual = 1;
    enforce(actual == expected, text("Expected: ", expected, " but got: ", actual));
}
