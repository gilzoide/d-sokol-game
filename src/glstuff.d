import glfw;

version (WebAssembly)
{
    extern(C) int gladLoadGLES2Loader(void* function(const(char)*));
    version = GLES;
}
else
{
    extern(C) int gladLoadGLLoader(void* function(const(char)*));
    version = GLCORE;
}

void hintGLVersion()
{
    version (GLES) 
    {
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    }
    else
    {
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    }
}

void loadGL()
{
    version (GLES)
    {
        gladLoadGLES2Loader(&glfwGetProcAddress);
    }
    else
    {
        gladLoadGLLoader(&glfwGetProcAddress);
    }
}
