import core.stdc.stdlib;
import sokol_app;
import sokol_time;

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
    int size = 0;
    private ulong _time;

    void frame()
    {
        double delta = stm_sec(stm_laptime(&_time));
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
