module ut.conv;

import ut;
import nogc.conv;


@("text with multiple arguments")
@safe unittest {
    const actual = () @nogc nothrow { return text(1, " ", 2.0, " ", true); }();
    actual[].shouldEqual("1 2.000000 true");
}

@("text with void[]")
@safe unittest {
    void[] arg;
    const actual = () @nogc nothrow { return text(arg); }();
    actual[].shouldEqual("[void]");
}

@("toWStringz")
@system unittest {
    import std.conv: to;

    const str = "pokémon";
    const exp = "pokémon".to!wstring;

    const act = () @nogc nothrow { return str.toWStringz(); }();
    act[0 .. 7].shouldEqual("pokémon".to!wstring);
}

@("text with at limit characters")
@safe unittest {
    const actual = () @nogc nothrow { return text!4("foo"); }();
    actual[].shouldEqual("foo");
}

@("text with 1 fewer char than needed")
@safe unittest {
    const actual = () @nogc nothrow { return text!3("foo"); }();
    actual[].shouldEqual("fo");
}

@("text enum")
@safe unittest {
    enum Enum { foo, bar, baz }
    Enum.bar.text[].shouldEqual("bar");
}
