/**
   This module implements utility code to throw exceptions in @nogc code.
 */
module nogc.exception;


import std.experimental.allocator.mallocator: Mallocator;


T enforce(E = NoGcException, T, Args...)
         (T value, auto ref Args args, in string file = __FILE__, in size_t line = __LINE__)
    if (is(typeof({ if (!value) {} })))
{
    import std.functional: forward;
    if(!value) NoGcException.throw_(File(file), Line(line), forward!args);
    return value;
}

alias NoGcException = NoGcExceptionImpl!Mallocator;

class NoGcExceptionImpl(A): Exception {

    import automem.traits: isGlobal;
    import automem.vector: StringA;
    import std.meta: anySatisfy;

    alias Allocator = A;

    // just to let enforce pass the right arguments to the constructor
    protected static struct Dummy {}
    protected enum isDummy(T) = is(T == Dummy);

    private StringA!Allocator _msg;
    static if(!isGlobal!Allocator) private Allocator _allocator;

    this(Args...)
        (auto ref Args args, string file = __FILE__, size_t line = __LINE__)
        if(isGlobal!Allocator && !anySatisfy!(isDummy, Args))
    {
        import std.functional: forward;
        this(Dummy(), file, line, forward!args);
    }

    ///
    @("exception can be constructed in @nogc code")
    @safe @nogc pure unittest {
        static const exception = new NoGcException();
    }

    this(Args...)
        (Allocator allocator, auto ref Args args, string file = __FILE__, size_t line = __LINE__)
        if(!anySatisfy!(isDummy, Args))
    {
        import std.functional: forward;
        this(Dummy(), file, line, forward!args);
        this._allocator = allocator;
    }

    // exists to be used from throw_
    protected this(Args...)
                  (in Dummy _, in string file, in size_t line, scope auto ref Args args)
        if(isGlobal!Allocator)
    {
        import nogc.conv: text, BUFFER_SIZE;
        import std.functional: forward;

        _msg = text!(BUFFER_SIZE, A)(forward!args);
        // Setting `Exception.msg` to the allocated memory in this class would
        // mean it could escape DIP1000 checks. The only sane alternative is
        // setting it to null
        super(null, file, line);
    }

    /**
       Throws a new NoGcException allowing to adjust the file name and line number
     */
    static void throw_(T = typeof(this), Args...)(in File file, in Line line, scope auto ref Args args) {
        import std.functional: forward;
        throw new T(Dummy(), file.value, line.value, forward!args);
    }

    ///  Manually free the msg
    final void free() @safe @nogc scope {
        _msg.free;
    }

    /**
       We can't let client code access `Exception.msg` since it's not scoped
       with DIP1000.
     */
    auto msg() @safe @nogc return scope {
        return _msg.range;
    }
}

struct File { string value; }
struct Line { size_t value; }


mixin template NoGcExceptionCtors() {

    import nogc.exception: File, Line;
    import automem.traits: isGlobal;
    import std.meta: anySatisfy;

    this(Args...)
        (auto ref Args args, string file = __FILE__, size_t line = __LINE__)
        if(isGlobal!Allocator && !anySatisfy!(isDummy, Args))
    {
        import std.functional: forward;
        super(forward!args, file, line);
    }

    this(Args...)
        (Allocator allocator, auto ref Args args, string file = __FILE__, size_t line = __LINE__)
        if(!anySatisfy!(isDummy, Args))
    {
        import std.functional: forward;
        super(allocator, forward!args, file, line);
    }


    // exists to be used from throw_
    protected this(Args...)
                  (in Dummy _, in string file, in size_t line, scope auto ref Args args)
        if(isGlobal!Allocator)
    {
        import std.functional: forward;
        super(_, file, line, forward!args);
    }

    /**
       Throws a new NoGcException allowing to adjust the file name and line number
     */
     static void throw_(T = typeof(this), Args...)(in File file, in Line line, scope auto ref Args args) {
        import std.functional: forward;
        typeof(super).throw_!T(file, line, forward!args);
    }
}
