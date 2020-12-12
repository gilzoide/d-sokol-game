/// Node in the object tree
mixin template Node()
{
    private alias T = typeof(this);

    enum _isNode = true;

    import std.meta : Reverse;
    import std.traits : Fields, FieldNameTuple, hasMember;
    void callSelfThenChildren(string method, Args...)(Args args)
    {
        static if (hasMember!(T, method))
        {
            __traits(getMember, this, method)(args);
        }
        static foreach (i, fieldName; FieldNameTuple!T)
        {
            static if (hasMember!(Fields!T[i], "_isNode") && Fields!T[i]._isNode)
            {
                __traits(getMember, this, fieldName).callSelfThenChildren!method(args);
            }
            else static if (hasMember!(Fields!T[i], method))
            {
                __traits(getMember, __traits(getMember, this, fieldName), method)(args);
            }
        }
    }
    void callReverseChildrenThenSelf(string method, Args...)(Args args)
    {
        static foreach (i, fieldName; Reverse!(FieldNameTuple!T))
        {
            static if (hasMember!(Fields!T[i], method))
            {
                __traits(getMember, __traits(getMember, this, fieldName), method)(args);
            }
        }
        static if (hasMember!(T, method))
        {
            __traits(getMember, this, method)(args);
        }
    }

    void initializeNode()
    {
        callSelfThenChildren!"initialize"();
        callReverseChildrenThenSelf!"lateInitialize"();
    }

    void _frame(double dt)
    {
        callSelfThenChildren!"update"(dt);
        callReverseChildrenThenSelf!"lateUpdate"(dt);

        callSelfThenChildren!"draw"();
        callReverseChildrenThenSelf!"lateDraw"();
    }

    static foreach (method; ["initialize", "lateInitialize", "update", "lateUpdate", "draw", "lateDraw"])
    {
        static if (!hasMember!(T, method))
        {
            mixin("void " ~ method ~ "(Args...)(Args args) {}");
        }
    }

    static T* create()
    {
        import memory : Memory;
        typeof(return) obj = Memory.make!T();
        obj.initializeNode();
        return obj;
    }
}


