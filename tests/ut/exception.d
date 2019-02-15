module ut.exception;


import ut;
import nogc.exception;


@("enforce")
@safe unittest {
    const(char)[] msg, file;
    size_t line, expectedLine;
    () @nogc {
        try {
            expectedLine = __LINE__ + 1;
            enforce(false, "foo", 5, "bar");
        } catch(NoGcException ex) {
            msg = ex.msg;
            file = ex.file;
            line = ex.line;
        }
    }();

    msg.shouldEqual("foo5bar");
    file.shouldEqual(__FILE__);
    line.shouldEqual(expectedLine);
}


version(FIXME) {
    @("TestAllocator")
        @safe @nogc unittest {

        import test_allocator;
        static TestAllocator allocator;

        alias MyException = NoGcExceptionImpl!(TestAllocator*);

        // just to make sure it compiles
        void func() {
            throw new MyException(&allocator, 42, " foobar ", 33.3);
        }
    }
}


@("malloc")
@safe @nogc unittest {

    try
        throw new NoGcException(42, " foobar ", 33.3);
    catch(NoGcException e) {
        assert(e.msg == "42 foobar 33.300000", e.msg);
        assert(e.file == __FILE__);
        assert(e.line == __LINE__ - 4);
    }
}


@("derived exception")
@safe @nogc unittest {

    static class MyException: NoGcException {

        static int numInstances;

        this(A...)(auto ref A args) {
            import std.functional: forward;
            super(forward!args);
            ++numInstances;
        }

        ~this() {
            --numInstances;
        }
    }

    try {
        assert(MyException.numInstances == 0);
        throw new MyException(42, " foobar ", 33.3);
    } catch(MyException e) {
        assert(MyException.numInstances == 1);
    }

    // FIXME: druntime issue
    version(fixme)
        assert(MyException.numInstances == 0);
}


@("throw.base")
@safe @nogc unittest {
    try
        NoGcException.throw_(File("foo.d"), Line(42),
                             "this is the message ", 33, " or ", 77.7, " hah");
    catch(Exception e) {
        assert(e.line == 42);
        debug {
            e.file.should == "foo.d";
            e.line.should == 42;
            e.msg.should == "this is the message 33 or 77.700000 hah";
        }
        return;
    }

    assert(false, "Didn't catch the exception");
}


@("throw.child")
@safe @nogc unittest {

    static class MyException: NoGcException {
        mixin NoGcExceptionCtors;
    }

    try
        MyException.throw_(File("foo.d"), Line(42),
                           "this is the message ", 33, " or ", 77.7, " hah");
    catch(MyException e) {
        assert(e.line == 42);
        debug {
            e.file.should == "foo.d";
            e.line.should == 42;
            e.msg.should == "this is the message 33 or 77.700000 hah";
        }
        return;
    }

    assert(false, "Didn't catch the exception");
}
