import core.stdc.stdlib;
import core.stdc.string;

struct Memory
{
    static void[] allocate(size_t size)
    {
        void* buffer = malloc(size);
        return buffer[0 .. size];
    }

    static T* makeUninitialized(T)()
    {
        return cast(T*) allocate(T.sizeof);
    }
    static T* make(T)(const T initialValue = T.init)
    {
        typeof(return) value = makeUninitialized!T();
        memcpy(value, &initialValue, T.sizeof);
        return value;
    }

    static T[] makeUninitializedArray(T)(size_t size)
    {
        auto bufferSize = size * T.sizeof;
        return cast(T[]) allocate(bufferSize);
    }
    static T[] makeArray(T)(size_t size, const T initialValue = T.init)
    {
        typeof(return) array = makeUninitializedArray!T(size);
        array[] = initialValue;
        return array;
    }
    static T[] makeArray(T, uint N)(const T[N] values)
    {
        typeof(return) array = makeArray!T(N);
        memcpy(array.ptr, values.ptr, values.sizeof);
        return array;
    }

    static void dispose(T)(ref T* pointer)
    {
        // TODO: destroy
        free(pointer);
        pointer = null;
    }

    static void dispose(T)(ref T[] array)
    {
        free(array.ptr);
        array = null;
    }

    struct Buffer
    {
        void* buffer;
        alias buffer this;

        @disable this(this);
        Buffer move()
        {
            Buffer b = { buffer: this.buffer };
            this.buffer = null;
            return b;
        }

        ~this()
        {
            dispose(buffer);
        }
    }

    struct Managed(T)
    {
        T value;
        alias value this;

        @disable this(this);

        ~this()
        {
            dispose(&this);
        }
    }

    struct ManagedArray(T)
    {
        T[] slice;
        alias slice this;

        @disable this(this);

        ~this()
        {
            dispose(slice.ptr);
        }
    }
}
