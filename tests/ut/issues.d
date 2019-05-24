module ut.issues;

import ut;
import nogc;


@("4")
@safe @nogc unittest {
    import core.stdc.stdio: puts;

    static struct S1 {
        int i = 42;
    }

    static struct Z {
        char* stringz() const @nogc @system {
            assert(0);
        }
    }

    static struct UnsafeAllocator {

        import std.experimental.allocator.mallocator: Mallocator;
        enum instance = UnsafeAllocator.init;

        void deallocate(void[] bytes) @nogc @system {
            Mallocator.instance.deallocate(bytes);
        }
        void[] allocate(size_t sz) @nogc @system {
            return Mallocator.instance.allocate(sz);
        }
    }

    S1 a;
    Z* z;
    auto t = text!(BUFFER_SIZE, UnsafeAllocator)(a, z);
}
