module ut.conv;

import ut;
import nogc.conv;


@("text with multiple arguments")
@safe unittest {
    const actual = () @nogc nothrow { return text(1, " ", 2.0, " ", true); }();
    actual.range.shouldEqual("1 2.000000 true");
}

@("text with void[]")
@safe unittest {
    void[] arg;
    const actual = () @nogc nothrow { return text(arg); }();
    actual.range.shouldEqual("[void]");
}

@("toWStringz")
@safe unittest {
    import std.conv: to;

    const str = "pokémon";
    const exp = "pokémon".to!wstring;

    const act = () @nogc nothrow { return str.toWStringz(); }();
    const slice = () @trusted @nogc { return act[0 .. 7]; }();
    slice.shouldEqual("pokémon".to!wstring);
}

@("text with at limit characters")
@safe unittest {
    const actual = () @nogc nothrow { return text!4("foo"); }();
    actual.range.shouldEqual("foo");
}

@("text with 1 fewer char than needed")
@safe unittest {
    const actual = () @nogc nothrow { return text!3("foo"); }();
    actual.range.shouldEqual("fo");
}

@("text.enum")
@safe @nogc unittest {
    import std.algorithm: equal;
    enum Enum { foo, bar, baz }
    const actual = Enum.bar.text;
    assert(equal(actual.range, "bar"));
}

@("text.struct")
@safe @nogc unittest {
    static struct Struct {
        int i;
        double d;
    }

    const actual = Struct(2, 33.3).text;
    debug actual.range.shouldEqual("Struct(2, 33.300000)");
}

@("text.string")
@safe @nogc unittest {
    const actual = "foobar".text;
    debug actual.range.shouldEqual("foobar");
}


@("text.inputrange")
@safe @nogc unittest {
    import std.range: only;
    const actual = only(0, 1, 2, 3).text;
    debug actual.range.shouldEqual("[0, 1, 2, 3]");
}

@("text.aa")
@safe unittest {
    const aa = ["foo": 1, "bar": 2];
    const actual = () @nogc { return aa.text; }();
    try
        debug actual.range.shouldEqual(`[foo: 1, bar: 2]`);
    catch(UnitTestException _)
        debug actual.range.shouldEqual(`[bar: 2, foo: 1]`);
}


@("toWtringz")
@safe unittest {
    const wstr = "foobar".toWStringz;
    wstr.range.shouldEqual("foobar"w ~ 0);
}


@("text.toWtringz")
@safe unittest {
    const wstr = text("foo ", 42, " bar").toWStringz;
    wstr.range.shouldEqual("foo 42 bar"w ~ 0);
}
