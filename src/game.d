import core.stdc.stdlib;
import glfw;
import sokol_app;

alias frameMethod = void delegate(double);
alias eventMethod = void delegate(const(sapp_event)*);

private struct GameObject
{
    void *object;
    frameMethod frame;
    eventMethod event;
}

struct Game(uint N = 8)
{
    GameObject[N] objects;
    uint size = 0;
    private double _time = 0;

    void frame()
    {
        immutable double now = glfwGetTime();
        immutable double delta = now - _time;
        _time = now;
        foreach (i; 0 .. size)
        {
            objects[i].frame(delta);
        }
    }

    void event(const(sapp_event)* ev)
    {
        foreach (i; 0 .. size)
        {
            objects[i].event(ev);
        }
    }

    T* createObject(T)()
    {
        typeof(return) object = T.create();
        addObject(object);
        return object;
    }

    void addObject(T)(T* object)
    {
        objects[size] = GameObject(object, &object._frame, &object._event);
        size++;
    }

    ~this()
    {
        foreach (i; 0 .. size)
        {
            free(objects[i].object);
        }
        size = 0;
    }
}
