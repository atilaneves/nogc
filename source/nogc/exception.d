/**
   This module implements utility code to throw exceptions in @nogc code.
 */
module nogc.exception;

enum BUFFER_SIZE = 1024;


T enforce(size_t bufferSize = BUFFER_SIZE, string file = __FILE__, size_t line = __LINE__, T, Args...)
         (T value, auto ref Args args)
    @trusted
    if (is(typeof({ if (!value) {} })))
{

    import std.conv: emplace;

    static void[__traits(classInstanceSize, NoGcException)] buffer = void;

    if (!value) {
        auto exception = emplace!NoGcException(buffer);
        () @trusted { exception.adjust!(bufferSize, file, line)(args); }();
        throw cast(const)exception;
    }
    return value;
}


class NoGcException: Exception {

    this() @safe @nogc nothrow pure {
        super("");
    }

    ///
    @("exception can be constructed in @nogc code")
    @safe @nogc pure unittest {
        static const exception = new NoGcException();
    }

    void adjust(size_t bufferSize = BUFFER_SIZE, string file = __FILE__, size_t line = __LINE__, A...)(auto ref A args) {
        import nogc.conv: text;

        this.file = file;
        this.line = line;

        this.msg = text!bufferSize(args);
    }

    ///
    @("adjust with only strings")
    @system unittest {
        import unit_threaded;
        auto exception = new NoGcException();
        () @nogc nothrow { exception.adjust("foo", "bar"); }();
        exception.msg.shouldEqual("foobar");
        exception.line.shouldEqual(__LINE__ - 2);
        exception.file.shouldEqual(__FILE__);
    }

}
