import core.stdc.stdlib;
import sokol_time;

alias frameMethod = void delegate(double);

private struct GameObject
{
    void *object;
    frameMethod frame;
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

    T* createObject(T)()
    {
        typeof(return) object = T.create();
        addObject(object);
        return object;
    }

    void addObject(T)(T* object)
    {
        objects[size] = GameObject(object, &object.frame);
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
