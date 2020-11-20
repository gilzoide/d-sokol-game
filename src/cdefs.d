extern(C):

int printf(const char*, ...);

version(WebAssembly)
void __assert(void *, void *, int)
{
}
