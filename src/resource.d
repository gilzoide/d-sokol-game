import std.meta;
import std.algorithm;

enum invalidId = uint.max;

struct Resource(T, string[] names, alias makeFunc, alias disposeFunc)
{
    T* content = null;
    alias content this;
    private uint id = invalidId;

    this(uint id)
    {
        this.id = id;
        content = null;
    }

    this(this other)
    {
        id = other.id;
        if (id != invalidId)
        {
            content = get(id);
        }
        else
        {
            content = null;
        }
    }

    ~this()
    {
        if (id != invalidId)
        {
            unref(id);
        }
    }

    static private T*[names.length] resources = null;
    static private uint[names.length] referenceCounts = 0;

    import std.format : format;
    static foreach (i, name; names)
    {
        mixin(format!"enum %s = Resource(%s);"(name, i));
    }

    static T* get(uint id)
    {
        if (referenceCounts[id] == 0)
        {
            resources[id] = makeFunc(id);
        }
        referenceCounts[id]++;
        return resources[id];
    }

    static void unref(uint id)
    {
        if (referenceCounts[id] > 0)
        {
            referenceCounts[id]--;
            if (referenceCounts[id] == 0)
            {
                if (resources[id])
                {
                    disposeFunc(resources[id]);
                }
                resources[id] = null;
            }
        }
    }
}
