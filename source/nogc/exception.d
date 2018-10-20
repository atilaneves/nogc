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
    if(!value) throw new NoGcException(NoGcException.Dummy(), file, line, forward!args);
    return value;
}

alias NoGcException = NoGcExceptionImpl!Mallocator;

class NoGcExceptionImpl(A): Exception {

    import automem.traits: isGlobal;
    import automem.vector: StringA;
    import std.meta: anySatisfy;

    alias Allocator = A;

    // just to let enforce pass the right arguments to the constructor
    private static struct Dummy {}
    private enum isDummy(T) = is(T == Dummy);

    private StringA!Allocator _msg;
    static if(!isGlobal!Allocator) private Allocator _allocator;

    this(Args...)
        (auto ref Args args, string file = __FILE__, size_t line = __LINE__)
    if(isGlobal!Allocator && !anySatisfy!(isDummy, Args))
    {
        import std.functional: forward;
        this(Dummy(), file, line, forward!args);
    }

    this(Args...)
        (Allocator allocator, auto ref Args args, string file = __FILE__, size_t line = __LINE__)
    if(!anySatisfy!(isDummy, Args))
    {
        import std.functional: forward;
        this(Dummy(), file, line, forward!args);
        this._allocator = allocator;
    }

    private this(Args...)
                (in Dummy _, in string file, in size_t line, scope auto ref Args args)
    if(isGlobal!Allocator)
    {
        import nogc.conv: text, BUFFER_SIZE;
        import std.functional: forward;

        _msg = text!(BUFFER_SIZE, A)(forward!args);
        super(_msg[], file, line);
    }

    ///
    @("exception can be constructed in @nogc code")
    @safe @nogc pure unittest {
        static const exception = new NoGcException();
    }

    /// Because DIP1008 doesn't do what it should yet
    final void free() @safe @nogc scope {
        _msg.free;
    }
}
