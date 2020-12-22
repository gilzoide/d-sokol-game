extern (C) nothrow:

version (LDC)
{
    void _d_array_slice_copy(void* dst, size_t dstlen, void* src, size_t srclen, size_t elemsz)
    {
        import ldc.intrinsics : llvm_memcpy;
        llvm_memcpy!size_t(dst, src, dstlen * elemsz, 0);
    }
}
else
{
    void[] _d_arraycopy(size_t size, void[] from, void[] to)
    {
        import core.stdc.string : memcpy;
        memcpy(to.ptr, from.ptr, to.length * size);
        return to;
    }
}

