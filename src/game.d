import betterclist;
import glfw;

import memory;

alias frameMethod = void delegate(double);

private struct GameObject
{
    void *object;
    frameMethod frame;
}

struct Game(uint N = 8)
{
    List!(GameObject, N) objects;
    double time = 0;

    void frame()
    {
        immutable double now = glfwGetTime();
        immutable double delta = now - time;
        time = now;
        foreach (o; objects)
        {
            o.frame(delta);
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
        objects.pushBack(GameObject(object, &object._frame));
    }

    ~this()
    {
        foreach (o; objects)
        {
            Memory.dispose(o.object);
        }
    }
}
