/// Node in the object tree
mixin template Node()
{
    private alias T = typeof(this);

    import std.traits : Fields, FieldNameTuple, hasMember;
    void initializeChildren()
    {
        static foreach (i, fieldName; FieldNameTuple!T)
        {
            static if (hasMember!(Fields!T[i], "initialize"))
            {
                __traits(getMember, this, fieldName).initialize();
            }
        }
    }

    void updateChildren(double dt)
    {
        static foreach (i, fieldName; FieldNameTuple!T)
        {
            static if (hasMember!(Fields!T[i], "update"))
            {
                __traits(getMember, this, fieldName).update(dt);
            }
        }
    }

    void drawChildren()
    {
        static foreach (i, fieldName; FieldNameTuple!T)
        {
            static if (hasMember!(Fields!T[i], "draw"))
            {
                __traits(getMember, this, fieldName).draw();
            }
        }
    }

    void drawChildrenBut(names...)()
    {
        import std.algorithm.comparison : among;
        static foreach (i, fieldName; FieldNameTuple!T)
        {
            static if (!fieldName.among(names) && hasMember!(Fields!T[i], "draw"))
            {
                __traits(getMember, this, fieldName).draw();
            }
        }
    }

    static if (!hasMember!(T, "initialize"))
    {
        void initialize()
        {
            initializeChildren();
        }
    }
    static if (!hasMember!(T, "update"))
    {
        void update(double dt)
        {
            updateChildren(dt);
        }
    }
    static if (!hasMember!(T, "draw"))
    {
        void draw()
        {
            drawChildren();
        }
    }

    static T* create()
    {
        import core.stdc.stdlib : malloc;
        typeof(return) obj = cast(T*) malloc(T.sizeof);
        *obj = T.init;
        obj.initialize();
        return obj;
    }
}


