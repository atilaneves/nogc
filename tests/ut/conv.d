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
@safe unittest {
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

@("text.enum")
@safe @nogc unittest {
    enum Enum { foo, bar, baz }
    const actual = Enum.bar.text;
    assert(actual[] == "bar", actual[]);
}

@("text.struct")
@safe @nogc unittest {
    static struct Struct {
        int i;
        double d;
    }

    const actual = Struct(2, 33.3).text;
    debug actual[].shouldEqual("Struct(2, 33.300000)");
}

@("text.string")
@safe @nogc unittest {
    const actual = "foobar".text;
    debug actual[].shouldEqual("foobar");
}


@("text.inputrange")
@safe @nogc unittest {
    import std.range: only;
    const actual = only(0, 1, 2, 3).text;
    debug actual[].shouldEqual("[0, 1, 2, 3]");
}

@("text.aa")
@safe unittest {
    const aa = ["foo": 1, "bar": 2];
    const actual = () @nogc { return aa.text; }();
    debug actual[].shouldEqual(`[foo: 1, bar: 2]`);
}
