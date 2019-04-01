/**
   Analogous to std.conv but @nogc
 */

module nogc.conv;


import localimport;
import std.experimental.allocator.mallocator: Mallocator;


enum BUFFER_SIZE = 1024;

@nogc:

auto text(size_t bufferSize = BUFFER_SIZE, Allocator = Mallocator, Args...)
         (scope auto ref Args args)
{
    import automem.vector: StringA;
    import core.stdc.stdio: snprintf;

    alias String = StringA!Allocator;

    scope char[bufferSize] buffer = void;
    String ret;

    foreach(ref const arg; args) {
        auto ptr = &buffer[0];
        auto len = buffer.length;
        auto fmt = format(arg);
        auto rawVal = () @trusted { return value!Allocator(arg); }();

        static if(__traits(compiles, rawVal.stringz))
            auto val = rawVal.stringz;
        else
            alias val = rawVal;

        const index = () @trusted { return snprintf(ptr, len, fmt, val); }();

        ret ~= index >= buffer.length - 1
            ? buffer[0 .. $ - 1]
            : buffer[0 .. index];
    }

    return ret;
}

private const(char)* format(T)(ref const(T) arg) if(is(T == int) || is(T == short) || is(T == byte)) {
    return &"%d"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == uint) || is(T == ushort) || is(T == ubyte)) {
    return &"%u"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == long)) {
    return &"%ld"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == ulong)) {
    return &"%lu"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == char)) {
    return &"%c"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == float)) {
    return &"%f"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == double)) {
    return &"%lf"[0];
}

private const(char)* format(T)(ref const(T) arg) if(from.std.traits.isPointer!T) {
    return &"%p"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == string)) {
    return &"%s"[0];
}

private const(char)* format(T)(ref const(T) arg) if(is(T == void[])) {
    return &"%s"[0];
}

private const(char)* format(T)(ref const(T) arg)
    if(is(T == enum) || is(T == bool) || (from.std.range.primitives.isInputRange!T && !is(T == string)) ||
       from.std.traits.isAssociativeArray!T || from.std.traits.isAggregateType!T)
{
    return &"%s"[0];
}


private auto value(Allocator = Mallocator, T)(ref const(T) arg)
    if((from.std.traits.isScalarType!T || from.std.traits.isPointer!T) && !is(T == enum) && !is(T == bool))
{
    return arg;
}

private auto value(Allocator = Mallocator, T)(ref const(T) arg) if(is(T == enum)) {
    import std.traits: EnumMembers;
    import std.conv: to;

    final switch(arg) {
        static foreach(member; EnumMembers!T) {
        case member:
            mixin(`return &"` ~ member.to!string ~ `"[0];`);
        }
    }
}


private auto value(Allocator = Mallocator, T)(ref const(T) arg) if(is(T == bool)) {
    return arg
        ? &"true"[0]
        : &"false"[0];
}


private auto value(Allocator = Mallocator, T)(ref const(T) arg) if(is(T == string)) {
    import automem.vector: StringA;
    return StringA!Allocator(arg);
}

private auto value(Allocator = Mallocator, T)(T arg) if(from.std.range.primitives.isInputRange!T && !is(T == string)) {

    import automem.vector: StringA;
    import std.range: hasLength, isForwardRange, walkLength, save;

    StringA!Allocator ret;

    ret ~= "[";

    static if(hasLength!T)
        const length = arg.length;
    else static if(isForwardRange!T)
        const length = arg.save.walkLength;
    else
        const length = size_t.max;

    size_t i;
    foreach(elt; arg) {
        ret ~= text!(BUFFER_SIZE, Allocator)(elt)[];
        if(++i < length) ret ~= ", ";
    }

    ret ~= "]";

    return ret;
}

private auto value(Allocator = Mallocator, T)(ref const(T) arg) if(from.std.traits.isAssociativeArray!T) {

    import automem.vector: StringA;

    StringA!Allocator ret;

    ret ~= "[";

    size_t i;
    foreach(key, val; arg) {
        ret ~= text!(BUFFER_SIZE, Allocator)(key)[];
        ret ~= ": ";
        ret ~= text!(BUFFER_SIZE, Allocator)(val)[];
        if(++i < arg.length) ret ~= ", ";
    }

    ret ~= "]";

    return ret;
}

private auto value(Allocator = Mallocator, T)(ref const(T) arg)
    if(from.std.traits.isAggregateType!T && !from.std.range.primitives.isInputRange!T)
{
    import automem.vector: StringA;

    StringA!Allocator ret;

    ret ~= T.stringof;
    ret ~= "(";

    foreach(i, elt; arg.tupleof) {
        ret ~= text!(BUFFER_SIZE, Allocator)(elt)[];
        if(i != arg.tupleof.length - 1) ret ~= ", ";
    }

    ret ~= ")";

    return ret;
}


private auto value(Allocator = Mallocator, T)(ref const(T) arg) if(is(T == void[])) {
    return &"[void]"[0];
}


auto toWStringz(Allocator = Mallocator, T)(in T str) {
    import automem.vector: Vector;
    import std.utf: byUTF;
    import std.traits: isSomeString;

    Vector!(immutable(wchar), Allocator) ret;
    ret.reserve(str.length * str[0].sizeof + 1);

    static if(isSomeString!T)
        alias range = str;
    else static if(__traits(compiles, str.range))
        auto range = str.range;
    else static if(__traits(compiles, str[]))
        auto range = str[];
    else
        static assert(false, "Don't know how to iterate by wchar on `" ~ T.stringof ~ "`");

    foreach(ch; range.byUTF!wchar)
        ret ~= ch;

    ret ~= 0;

    return ret;
}
