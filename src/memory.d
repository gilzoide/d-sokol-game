import core.stdc.stdlib;
import core.stdc.string;

struct Memory
{
    alias allocate = malloc;
    alias dispose = free;

    static T* make(T)(const T initialValue = T.init)
    {
        typeof(return) value = cast(T*) allocate(T.sizeof);
        memcpy(value, &initialValue, T.sizeof);
        return value;
    }

    static T[] makeArray(T)(uint size)
    {
        auto bufferSize = size * T.sizeof;
        void* buffer = allocate(bufferSize);
        return cast(T[]) buffer[0 .. bufferSize];
    }
    static T[] makeArray(T, uint N)(const T[N] values)
    {
        typeof(return) array = makeArray!T(N);
        memcpy(array.ptr, values.ptr, values.sizeof);
        return array;
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
