import core.stdc.stdlib;
import sokol_time;

alias updateMethod = void delegate(double);
alias drawMethod = void delegate();

private struct GameObject
{
    void *object;
    updateMethod update;
    drawMethod draw;
}

struct Game(uint N = 8)
{
    GameObject[N] objects;
    int size = 0;
    private ulong _time;

    void update(double dt)
    {
        foreach (i; 0 .. size)
        {
            objects[i].update(dt);
        }
    }

    void draw()
    {
        foreach (i; 0 .. size)
        {
            objects[i].draw();
        }
    }

    void frame()
    {
        double delta = stm_sec(stm_laptime(&_time));
        update(delta);
        draw();
    }

    void addObject(T)(T* object)
    {
        objects[size] = GameObject(object, &object.update, &object.draw);
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

/// The global game instance
__gshared Game!2 instance;
