extern(C):

int printf(const char*, ...);


version(WebAssembly)
{
    alias em_callback_func = void function();
    void emscripten_set_main_loop(em_callback_func, int, int);

    void __assert(void *, void *, int)
    {
    }
}
