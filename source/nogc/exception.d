/**
   This module implements utility code to throw exceptions in @nogc code.
 */
module nogc.exception;


import std.experimental.allocator.mallocator: Mallocator;


enum BUFFER_SIZE = 1024;


T enforce(E = NoGcException, size_t bufferSize = BUFFER_SIZE, string file = __FILE__, size_t line = __LINE__, T, Args...)
         (T value, auto ref Args args)
    @trusted
    if (is(typeof({ if (!value) {} })))
{

    import std.conv: emplace;

    static void[__traits(classInstanceSize, E)] buffer = void;

    if (!value) {
        auto exception = emplace!E(buffer);
        exception.adjust!(bufferSize, file, line)(args);
        throw cast(const)exception;
    }
    return value;
}

alias NoGcException = NoGcExceptionImpl!Mallocator;

class NoGcExceptionImpl(A): Exception {

    import automem.vector: Vector;

    alias Allocator = A;

    version(none) private Vector!(immutable char, A) _msg;

    this() @safe @nogc nothrow pure {
        super(null);
    }

    version(none) {
        this(string file = __FILE__, size_t line = __LINE__, Args...)
            (auto ref Allocator allocator, auto ref Args args)
            {
                import nogc.conv: text;

                super(null);

                this.file = file;
                this.line = line;

                _msg = Vector!(immutable char, A)(allocator, () @trusted { return text(args); }());
            }
    }

    ///
    @("exception can be constructed in @nogc code")
    @safe @nogc pure unittest {
        static const exception = new NoGcException();
    }

    void adjust(size_t bufferSize = BUFFER_SIZE, string file = __FILE__, size_t line = __LINE__, A...)
               (auto ref A args)
    {
        import nogc.conv: text;

        this.file = file;
        this.line = line;

        super.msg = text!bufferSize(args);
    }

    const(char)[] msg() @safe @nogc pure nothrow const scope {
        version(none) return _msg.length ? _msg[] : super.msg;
        else return super.msg;
    }

    ///
    @("adjust with only strings")
    @system unittest {
        import unit_threaded.should;
        auto exception = new NoGcException();
        () @nogc nothrow { exception.adjust("foo", "bar"); }();
        exception.msg.shouldEqual("foobar");
        exception.line.shouldEqual(__LINE__ - 2);
        exception.file.shouldEqual(__FILE__);
    }

}
